#include "SystemTheme.h"

#include "core/Logging.h"
#include "MaterialColors.h"
#include "PlasmaColors.h"
#include "PlatformColors.h"
#include "TerminalColors.h"
#include "ThemeColors.h"

#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QGuiApplication>
#include <QSettings>
#include <QStandardPaths>
#include <QStyleHints>

namespace {

const QString kSourceKey = QStringLiteral("appearance/colorSource");

struct FileSource
{
    QString id;
    QString name;
    QString path;
};

QString underHome(QStandardPaths::StandardLocation location, const QString &relative)
{
    const QString root = QStandardPaths::writableLocation(location);
    return root.isEmpty() ? QString() : root + QLatin1Char('/') + relative;
}

bool desktopShellsRunHere()
{
#if defined(Q_OS_UNIX) && !defined(Q_OS_MACOS)
    return true;
#else
    return false;
#endif
}

QList<FileSource> materialFiles()
{
    if (!desktopShellsRunHere())
        return {};
    return {
        {QStringLiteral("quickshell"), QStringLiteral("Quickshell"),
         underHome(QStandardPaths::GenericStateLocation,
                   QStringLiteral("quickshell/user/generated/colors.json"))},
        {QStringLiteral("matugen-config"), QStringLiteral("Matugen"),
         underHome(QStandardPaths::GenericConfigLocation, QStringLiteral("matugen/colors.json"))},
        {QStringLiteral("matugen-cache"), QStringLiteral("Matugen"),
         underHome(QStandardPaths::GenericCacheLocation, QStringLiteral("matugen/colors.json"))},
    };
}

QList<FileSource> terminalFiles()
{
    if (!desktopShellsRunHere())
        return {};
    return {
        {QStringLiteral("wallust"), QStringLiteral("Wallust"),
         underHome(QStandardPaths::GenericCacheLocation, QStringLiteral("wallust/colors.json"))},
        {QStringLiteral("pywal"), QStringLiteral("Pywal"),
         underHome(QStandardPaths::GenericCacheLocation, QStringLiteral("wal/colors.json"))},
    };
}

QString plasmaFile()
{
    if (!desktopShellsRunHere())
        return {};
    return underHome(QStandardPaths::GenericConfigLocation, QStringLiteral("kdeglobals"));
}

QString cutefishConfigFile()
{
    if (!desktopShellsRunHere())
        return {};
    const QString aevisPath = underHome(QStandardPaths::GenericConfigLocation, QStringLiteral("aevis/theme.conf"));
    if (QFile::exists(aevisPath))
        return aevisPath;
    return underHome(QStandardPaths::GenericConfigLocation, QStringLiteral("cutefishos/theme.conf"));
}

Qt::ColorScheme readCutefishScheme()
{
    for (const auto &rel : { QStringLiteral("aevis/theme.conf"), QStringLiteral("cutefishos/theme.conf") }) {
        const QString path = underHome(QStandardPaths::GenericConfigLocation, rel);
        if (!path.isEmpty() && QFile::exists(path)) {
            const QSettings settings(path, QSettings::IniFormat);
            if (settings.contains(QStringLiteral("General/DarkMode"))) {
                return settings.value(QStringLiteral("General/DarkMode")).toBool()
                    ? Qt::ColorScheme::Dark
                    : Qt::ColorScheme::Light;
            }
        }
    }
    return Qt::ColorScheme::Unknown;
}

}

namespace theme {

SystemTheme::SystemTheme(QObject *parent)
    : QObject(parent)
    , m_platformScheme(QGuiApplication::styleHints()->colorScheme())
    , m_preferredId(QSettings().value(kSourceKey).toString())
{
    discover();

    if (const ColorSource *source = active())
        qCInfo(logTheme) << "system colors from" << source->name() << source->location();
    else
        qCInfo(logTheme) << "no system color source, using the built-in palette";
}

SystemTheme &SystemTheme::instance()
{
    static auto *systemTheme = new SystemTheme(QCoreApplication::instance());
    return *systemTheme;
}

SystemTheme *SystemTheme::create(QQmlEngine *, QJSEngine *)
{
    QQmlEngine::setObjectOwnership(&instance(), QQmlEngine::CppOwnership);
    return &instance();
}

bool SystemTheme::dark() const
{
    return colorScheme() != Qt::ColorScheme::Light;
}

QString SystemTheme::sourceName() const
{
    const ColorSource *source = active();
    return source ? source->name() : QString();
}

QList<ColorSourceInfo> SystemTheme::sources() const
{
    const ColorSource *current = active();

    QList<ColorSourceInfo> found;
    for (const ColorSource *source : m_sources) {
        if (source->available())
            found.append(source->info(source == current));
    }
    return found;
}

const ColorSource::Roles &SystemTheme::roles(bool dark) const
{
    static const ColorSource::Roles kNone;
    const ColorSource *source = active();
    return source ? source->roles(dark) : kNone;
}

QColor SystemTheme::accent() const
{
    const ColorSource *source = active();
    return source ? source->accent() : QColor();
}

void SystemTheme::select(const QString &id)
{
    if (m_preferredId == id)
        return;
    m_preferredId = id;
    QSettings().setValue(kSourceKey, id);
    Q_EMIT changed();
}

void SystemTheme::discover()
{
    m_sources.append(new ThemeColors(this));

    for (const FileSource &file : materialFiles()) {
        if (!file.path.isEmpty())
            m_sources.append(new MaterialColors(file.id, file.name, file.path, this));
    }

    m_sources.append(new PlatformColors(this));

    if (const QString plasma = plasmaFile(); !plasma.isEmpty())
        m_sources.append(new PlasmaColors(plasma, this));

    for (const FileSource &file : terminalFiles()) {
        if (!file.path.isEmpty())
            m_sources.append(new TerminalColors(file.id, file.name, file.path, this));
    }

    for (ColorSource *source : std::as_const(m_sources)) {
        connect(source, &ColorSource::changed, this, &SystemTheme::changed);
        source->refresh();
    }

    for (const auto &rel : { QStringLiteral("aevis/theme.conf"), QStringLiteral("cutefishos/theme.conf") }) {
        const QString path = underHome(QStandardPaths::GenericConfigLocation, rel);
        if (!path.isEmpty()) {
            const QString dir = QFileInfo(path).absolutePath();
            if (QDir(dir).exists())
                m_watcher.addPath(dir);
            if (QFile::exists(path))
                m_watcher.addPath(path);
        }
    }
    connect(&m_watcher, &QFileSystemWatcher::fileChanged, this, &SystemTheme::changed);
    connect(&m_watcher, &QFileSystemWatcher::directoryChanged, this, &SystemTheme::changed);

    if (auto *hints = QGuiApplication::styleHints()) {
        connect(hints, &QStyleHints::colorSchemeChanged, this, [this](Qt::ColorScheme scheme) {
            m_platformScheme = scheme;
            Q_EMIT changed();
        });
    }
}

const ColorSource *SystemTheme::active() const
{
    for (const ColorSource *source : m_sources) {
        if (source->available() && source->id() == m_preferredId)
            return source;
    }
    for (const ColorSource *source : m_sources) {
        if (source->available())
            return source;
    }
    return nullptr;
}

Qt::ColorScheme SystemTheme::colorScheme() const
{
    const Qt::ColorScheme cutefish = readCutefishScheme();
    if (cutefish != Qt::ColorScheme::Unknown)
        return cutefish;

    for (const ColorSource *source : m_sources) {
        if (source->id() == QLatin1String("platform") && source->colorScheme() != Qt::ColorScheme::Unknown)
            return source->colorScheme();
    }

    if (auto *hints = QGuiApplication::styleHints(); hints && hints->colorScheme() != Qt::ColorScheme::Unknown)
        return hints->colorScheme();

    if (m_platformScheme != Qt::ColorScheme::Unknown)
        return m_platformScheme;

    if (!m_preferredId.isEmpty()) {
        if (const ColorSource *source = active();
            source && source->colorScheme() != Qt::ColorScheme::Unknown) {
            return source->colorScheme();
        }
    }

    for (const ColorSource *source : m_sources) {
        if (source->available() && source->colorScheme() != Qt::ColorScheme::Unknown)
            return source->colorScheme();
    }

    return Qt::ColorScheme::Dark;
}

}
