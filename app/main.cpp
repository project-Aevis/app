#include "control/DownloadActivity.h"
#include "core/AppInfo.h"
#include "core/Fonts.h"
#include "core/Logging.h"
#include "core/Localization.h"
#include "diagnostics/Diagnostics.h"
#include "diagnostics/DiagnosticsSettings.h"
#include "innertube/Session.h"
#include "library/ImageCache.h"
#include "media/ArtworkProvider.h"
#include "media/PlaybackController.h"
#include "media/QueueSync.h"
#include "platform/Desktop.h"
#include "platform/SessionStore.h"
#include "platform/SingleInstance.h"
#include "platform/WindowChrome.h"
#include "platform/WindowState.h"
#include "plugin/PluginRegistry.h"
#include "theme/ThemeLibrary.h"
#include "update/Updater.h"

#include <QApplication>
#include <QFont>
#include <QIcon>
#include <QPixmapCache>
#include <QProcess>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QQuickWindow>
#include <QTimer>
#include <QtWebEngineQuick>

#if defined(Q_OS_LINUX) && defined(__GLIBC__)
#include <malloc.h>
#endif

namespace {

QQuickWindow *shellWindow(const QQmlApplicationEngine &engine)
{
    const QList<QObject *> roots = engine.rootObjects();
    return roots.isEmpty() ? nullptr : qobject_cast<QQuickWindow *>(roots.constFirst());
}

int run(int argc, char *argv[], QStringList &relaunch)
{
    QApplication app(argc, argv);
    QPixmapCache::setCacheLimit(4096);
#ifndef Q_OS_MACOS
    QApplication::setWindowIcon(QIcon(QStringLiteral(":/icons/ht-music.svg")));
#endif
    core::fonts::install();

    QFont appFont(QStringLiteral("SF Pro Text"));
    appFont.setPixelSize(13);
    appFont.setStyleStrategy(QFont::PreferAntialias);
    QApplication::setFont(appFont);

    platform::SingleInstance running;
    if (!running.claim())
        return 0;

    diagnostics::DiagnosticsSettings &reporting = diagnostics::DiagnosticsSettings::instance();
    reporting.restore();

    const auto &localization = core::Localization::instance();
    theme::ThemeLibrary::instance().restore();

    library::ImageCache imageCache;
    QQmlApplicationEngine engine;
    engine.addImageProvider(QStringLiteral("art"), new media::ArtworkProvider(imageCache));

    auto *cleanupTimer = new QTimer(&app);
    cleanupTimer->setInterval(30000);
    QObject::connect(cleanupTimer, &QTimer::timeout, &app, [&engine] {
        engine.trimComponentCache();
#if defined(Q_OS_LINUX) && defined(__GLIBC__)
        malloc_trim(0);
#endif
    });
    cleanupTimer->start();

    QObject::connect(&localization, &core::Localization::resolvedChanged, &engine,
                     [&engine] { engine.retranslate(); });

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed, &app,
                     [] { QCoreApplication::exit(1); }, Qt::QueuedConnection);

    engine.loadFromModule("HtMusic.App", "Main");
    reporting.bind(engine);

    QQuickWindow *window = shellWindow(engine);
    platform::WindowChrome &chrome = platform::WindowChrome::instance();
    chrome.bind(window);
    platform::WindowState::instance().bind(window);

    auto &playback = media::PlaybackController::instance();
    platform::Desktop const desktop(playback, window);
    QObject::connect(&running, &platform::SingleInstance::raiseRequested, &desktop,
                     &platform::Desktop::raise);

    platform::SessionStore session(playback);
    session.restore();
    media::QueueSync queueSync(playback);
    queueSync.start(session.playedAt());

    control::DownloadActivity const downloadActivity;
    update::Updater::instance().start();

    plugin::PluginRegistry &plugins = plugin::PluginRegistry::instance();
    plugins.restore();
    QObject::connect(&app, &QApplication::aboutToQuit, &plugins,
                     [&plugins] { plugins.shutDown(); });

    const int status = QApplication::exec();
    innertube::Session::instance().finishTrackingRequests();
    if (chrome.relaunching())
        relaunch = QStringList(QCoreApplication::applicationFilePath())
            + QCoreApplication::arguments().mid(1);
    return status;
}

}

int main(int argc, char *argv[])
{
#if defined(Q_OS_LINUX) && defined(__GLIBC__)
    mallopt(M_ARENA_MAX, 2);
    mallopt(M_TRIM_THRESHOLD, 128 * 1024);
#endif

    core::AppInfo::identify();
    core::logging::install();
    diagnostics::guardTermination();

    if (!qEnvironmentVariableIsSet("QTWEBENGINE_CHROMIUM_FLAGS")) {
        qputenv("QTWEBENGINE_CHROMIUM_FLAGS",
                "--renderer-process-limit=1 "
                "--disable-gpu-shader-disk-cache "
                "--enable-low-end-device-mode "
                "--js-flags=--max-old-space-size=64 "
                "--disable-features=BackForwardCache,MediaEngagementBypassAutoplayPolicies,PreloadMediaEngagementData,Translate "
                "--disable-site-isolation-trials");
    }

    QQuickStyle::setStyle(QStringLiteral("Basic"));
    QtWebEngineQuick::initialize();

    QStringList relaunch;
    const int status = run(argc, argv, relaunch);
    if (!relaunch.isEmpty())
        QProcess::startDetached(relaunch.constFirst(), relaunch.mid(1));

    diagnostics::shutDown();
    return status;
}
