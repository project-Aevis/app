import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import QtQuick.Shapes
import FishUI 1.0 as FishUI
import HtMusic

Window {
    id: window

    readonly property bool sheetVisible: settings.visible || login.visible || plugins.visible
        || release.visible
    readonly property int chromeZ: Overlay.overlay ? Overlay.overlay.z + 1 : 1
    readonly property real windowRadius: WindowState.maximized ? 0 : 16

    x: WindowState.initialX
    y: WindowState.initialY
    width: WindowState.initialWidth
    height: WindowState.initialHeight
    minimumWidth: 1040
    minimumHeight: 680 + titleBar.height
    flags: WindowChrome.windowFlags
    visible: true
    color: "transparent"
    title: AppInfo.name

    onClosing: close => {
        if (SystemSettings.background !== SystemSettings.Unavailable && SystemSettings.closeToTray) {
            close.accepted = false;
            window.hide();
        }
    }

    Connections {
        target: Browser

        function onPageChanged() {
            search.follow(Browser.searchQuery);
        }

        function onPlayRequested(tracks, index, source) {
            PlaybackController.playQueue(tracks, index, source);
        }

        function onResolutionFailed(message) {
            Toasts.show(message, true);
        }

        function onLinkOpened() {
            fullPlayer.open = false;
        }

        function onTracksResolved(tracks, intent) {
            switch (intent) {
            case "next":
                PlaybackController.playNext(tracks);
                Toasts.show(qsTr("Playing %n songs next", "", tracks.length));
                break;
            case "queue":
                PlaybackController.enqueue(tracks);
                Toasts.show(qsTr("Added %n songs to queue", "", tracks.length));
                break;
            case "download":
                Downloads.keep(tracks);
                break;
            case "save":
                PlaylistTargets.show(tracks.map(track => track.videoId));
                break;
            }
        }
    }

    Connections {
        target: Downloads

        function onFeedback(message) {
            Toasts.show(message);
        }
    }

    Connections {
        target: Uploads

        function onFeedback(message, error) {
            Toasts.show(message, error);
        }
    }

    // Cutefish Window Shadows
    FishUI.WindowShadow {
        view: window
        radius: window.windowRadius
        strength: window.active ? 0.8 : 0.5
    }

    // Cutefish Window Blur
    FishUI.WindowBlur {
        id: windowBlur
        view: window
        windowRadius: window.windowRadius
        enabled: FishUI.Theme.blurEnabled
    }

    Item {
        id: shellMask
        anchors.fill: shell
        visible: false

        Rectangle {
            anchors.fill: parent
            radius: window.windowRadius
        }
    }

    Rectangle {
        id: windowFrame
        anchors.fill: parent
        radius: window.windowRadius
        color: "transparent"
        antialiasing: true
        z: 50

        border.width: WindowState.maximized ? 0 : 1
        border.color: FishUI.Theme.glassBorderColor

        // Inner Specular Glass Rim
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: Math.max(0, parent.radius - 1)
            color: "transparent"
            border.width: 1
            border.color: FishUI.Theme.glassSpecularColor
            visible: !WindowState.maximized
        }
    }

    WindowTitleBar {
        id: titleBar

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 0
        visible: false
        z: window.chromeZ
    }

    FocusScope {
        id: shell

        anchors.fill: parent
        anchors.topMargin: titleBar.height
        focus: true

        layer.enabled: !WindowState.maximized
        layer.smooth: true
        layer.effect: OpacityMask {
            maskSource: shellMask
        }

        Keys.onPressed: event => {
            if (pages.modalActive) {
                event.accepted = true;
                return;
            }
            if (settings.open) {
                if (event.key === Qt.Key_Escape)
                    settings.open = false;
                event.accepted = true;
                return;
            }
            const key = ShortcutKeys.resolve(event.key, event.nativeScanCode);
            switch (key) {
            case Qt.Key_Space:
                PlaybackController.toggle();
                break;
            case Qt.Key_Right:
                if (PlaybackController.episode)
                    PlaybackController.skip(30000);
                else
                    PlaybackController.next();
                break;
            case Qt.Key_Left:
                if (PlaybackController.episode)
                    PlaybackController.skip(-10000);
                else
                    PlaybackController.previous();
                break;
            case Qt.Key_Up:
                PlaybackController.stepVolume(1);
                break;
            case Qt.Key_Down:
                PlaybackController.stepVolume(-1);
                break;
            case Qt.Key_Escape:
                if (login.open)
                    login.open = false;
                else if (fullPlayer.open)
                    fullPlayer.open = false;
                else
                    Browser.back();
                break;
            case Qt.Key_Slash:
                search.focusInput();
                break;
            case Qt.Key_P:
                fullPlayer.open = !fullPlayer.open;
                break;
            case Qt.Key_M:
                rail.expanded = !rail.expanded;
                break;
            default:
                if (key >= Qt.Key_1 && key <= Qt.Key_4)
                    Browser.showSection(key - Qt.Key_1);
                return;
            }
            event.accepted = true;
        }

        NavRail {
            id: rail

            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: implicitWidth
            enabled: !pages.modalActive && !window.sheetVisible
            current: Browser.section
            onNavigateRequested: index => {
                fullPlayer.open = false;
                Browser.showSection(index);
            }
            onSearchRequested: {
                fullPlayer.open = false;
                search.focusInput();
            }
            onPluginsRequested: plugins.open = true
            onSettingsRequested: settings.open = true
            onAccountRequested: {
                if (Account.signedIn) {
                    Browser.showHistory();
                } else {
                    login.open = true;
                }
            }
            onNewPlaylistRequested: {
                if (Account.signedIn) {
                    Browser.showSection(2);
                    Browser.showLibraryTab(1);
                } else {
                    login.open = true;
                }
            }
        }

        Item {
            id: content

            anchors.left: rail.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            clip: true

            // Flat content background like Cutefish OS with aperture for floating player bar
            Shape {
                id: contentBg

                anchors.fill: parent
                z: -1

                ShapePath {
                    fillColor: Theme.darkMode ? "#141416" : "#FFFFFF"
                    strokeColor: "transparent"
                    fillRule: ShapePath.OddEvenFill

                    // Flat main background
                    PathRectangle {
                        x: 0
                        y: 0
                        width: contentBg.width
                        height: contentBg.height
                    }

                    // Cutout: Floating Player Bar
                    PathRectangle {
                        x: playerBar.x
                        y: playerBar.y
                        width: playerBar.visible ? playerBar.width : 0
                        height: playerBar.visible ? playerBar.height : 0
                        radius: playerBar.radius
                    }
                }
            }

            Item {
                id: topBar

                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: Theme.spaced(8)
                anchors.leftMargin: Theme.spacing.gutter
                anchors.rightMargin: Theme.spacing.gutter
                height: Theme.sized(44)
                z: 2
                enabled: !pages.modalActive && !window.sheetVisible

                DragHandler {
                    target: null
                    onActiveChanged: {
                        if (active)
                            WindowChrome.startMove();
                    }
                }

                TapHandler {
                    gesturePolicy: TapHandler.DragThreshold
                    onDoubleTapped: WindowChrome.toggleMaximized()
                }

                // Capsule: Back Button
                Item {
                    id: backCapsule

                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: Theme.sized(36)
                    height: Theme.sized(36)

                    Rectangle {
                        id: backBg
                        anchors.fill: parent
                        radius: width / 2
                        color: Theme.darkMode
                            ? (backMouse.pressed ? Qt.rgba(1, 1, 1, 0.05)
                                : (backMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.14)
                                : Qt.rgba(1, 1, 1, 0.08)))
                            : (backMouse.pressed ? Qt.rgba(0, 0, 0, 0.12)
                                : (backMouse.containsMouse ? Qt.rgba(0, 0, 0, 0.09)
                                : Qt.rgba(0, 0, 0, 0.05)))
                        border.width: 1
                        border.color: Theme.darkMode
                            ? Qt.rgba(1.0, 1.0, 1.0, 0.10)
                            : Qt.rgba(0.0, 0.0, 0.0, 0.06)

                        AppleIcon {
                            anchors.centerIn: parent
                            name: "chevron_left"
                            size: Theme.sized(16)
                            color: Browser.canGoBack ? Theme.colOnSurface : Theme.colInactive
                        }

                        scale: backMouse.pressed ? 0.92 : (backMouse.containsMouse ? 1.05 : 1.0)
                        Behavior on scale {
                            NumberAnimation {
                                duration: Theme.duration.fast
                                easing.type: Easing.BezierSpline
                                easing.bezierCurve: Theme.curve.expressiveEffects
                            }
                        }
                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.duration.fast
                            }
                        }

                        MouseArea {
                            id: backMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Browser.canGoBack ? Qt.PointingHandCursor : Qt.ArrowCursor
                            enabled: Browser.canGoBack
                            onClicked: {
                                fullPlayer.open = false;
                                Browser.back();
                            }
                        }
                    }
                }

                // Capsule: Reload Button
                Item {
                    id: reloadCapsule

                    anchors.left: backCapsule.right
                    anchors.leftMargin: Theme.spaced(8)
                    anchors.verticalCenter: parent.verticalCenter
                    width: Theme.sized(36)
                    height: Theme.sized(36)

                    Rectangle {
                        id: reloadBg
                        anchors.fill: parent
                        radius: width / 2
                        color: Theme.darkMode
                            ? (reloadMouse.pressed ? Qt.rgba(1, 1, 1, 0.05)
                                : (reloadMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.14)
                                : Qt.rgba(1, 1, 1, 0.08)))
                            : (reloadMouse.pressed ? Qt.rgba(0, 0, 0, 0.12)
                                : (reloadMouse.containsMouse ? Qt.rgba(0, 0, 0, 0.09)
                                : Qt.rgba(0, 0, 0, 0.05)))
                        border.width: 1
                        border.color: Theme.darkMode
                            ? Qt.rgba(1.0, 1.0, 1.0, 0.10)
                            : Qt.rgba(0.0, 0.0, 0.0, 0.06)

                        AppleIcon {
                            id: reloadIcon
                            anchors.centerIn: parent
                            name: "refresh"
                            size: Theme.sized(15)
                            color: (Browser.page && !Browser.page.loading) ? Theme.colOnSurface : Theme.colInactive
                            rotation: Browser.page && Browser.page.loading ? 360 : 0
                            Behavior on rotation {
                                NumberAnimation { duration: 600; loops: Animation.Infinite }
                            }
                        }

                        scale: reloadMouse.pressed ? 0.92 : (reloadMouse.containsMouse ? 1.05 : 1.0)
                        Behavior on scale {
                            NumberAnimation {
                                duration: Theme.duration.fast
                                easing.type: Easing.BezierSpline
                                easing.bezierCurve: Theme.curve.expressiveEffects
                            }
                        }
                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.duration.fast
                            }
                        }

                        MouseArea {
                            id: reloadMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: (Browser.page && !Browser.page.loading) ? Qt.PointingHandCursor : Qt.ArrowCursor
                            enabled: !!Browser.page && !Browser.page.loading
                            onClicked: Browser.reloadPage()
                        }
                    }
                }

                // Capsule: Search Bar
                SearchBar {
                    id: search

                    anchors.left: reloadCapsule.right
                    anchors.leftMargin: Theme.spaced(14)
                    anchors.right: detailShareBtn.visible ? detailShareBtn.left : (connection.visible ? connection.left : (notifications.visible ? notifications.left : account.left))
                    anchors.rightMargin: Theme.spaced(14)
                    anchors.verticalCenter: parent.verticalCenter
                    placeholder: Connectivity.online ? qsTr("Artists, Songs, Lyrics, and More...")
                        : qsTr("Search your downloads")
                    suggestionsEnabled: true
                    pasteEnabled: true
                    glass: fullPlayer.visible
                    onEditingFinished: shell.forceActiveFocus()
                    onAccepted: query => {
                        fullPlayer.open = false;
                        Browser.search(query);
                        shell.forceActiveFocus();
                    }
                    onPasteRequested: {
                        if (!Browser.openLink(Clipboard.text()))
                            Toasts.show(qsTr("There is no YouTube link or video ID in the clipboard."), true);
                    }
                }

                IconButton {
                    id: detailShareBtn

                    anchors.right: detailMoreBtn.left
                    anchors.rightMargin: Theme.spaced(4)
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !!Browser.page && Browser.page.detail
                    icon: "share"
                    iconSize: Theme.sized(16)
                    diameter: Theme.sized(32)
                    colIcon: Theme.colOnSurface
                    colBackground: Theme.darkMode ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.05)
                    Accessible.name: qsTr("Share")
                    onClicked: if (Browser.page) Actions.share(Browser.page.entry)
                }

                IconButton {
                    id: detailMoreBtn

                    anchors.right: connection.visible ? connection.left : (notifications.visible ? notifications.left : account.left)
                    anchors.rightMargin: Theme.spaced(10)
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !!Browser.page && Browser.page.detail
                    icon: "more_horiz"
                    iconSize: Theme.sized(16)
                    diameter: Theme.sized(32)
                    colIcon: Theme.colOnSurface
                    colBackground: Theme.darkMode ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.05)
                    Accessible.name: qsTr("More actions")
                    onClicked: if (Browser.page) Actions.share(Browser.page.entry)
                }

                ConnectionChip {
                    id: connection

                    anchors.right: notifications.visible ? notifications.left : account.left
                    anchors.rightMargin: Theme.spaced(8)
                    anchors.verticalCenter: parent.verticalCenter
                    width: implicitWidth
                    height: implicitHeight
                    z: 1
                    glass: fullPlayer.visible
                }

                ControlCenterButton {
                    id: notifications

                    anchors.right: account.left
                    anchors.rightMargin: Theme.spaced(10)
                    anchors.verticalCenter: parent.verticalCenter
                    z: 1
                }

                // Capsule: Account Profile
                AccountButton {
                    id: account

                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    z: 1
                    glass: fullPlayer.visible
                    onSettingsRequested: settings.open = true
                    onHistoryRequested: {
                        fullPlayer.open = false;
                        Browser.showHistory();
                    }
                }

            }

            PageView {
                id: pages

                anchors.top: topBar.bottom
                anchors.topMargin: Theme.spaced(12)
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.spacing.gutter - Theme.spacing.bleed
                anchors.rightMargin: Theme.spacing.gutter - Theme.spacing.bleed
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Theme.spaced(14)
                enabled: !fullPlayer.visible && !window.sheetVisible
            }

            PlayerBar {
                id: playerBar

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Theme.spaced(14)
                z: 10
                enabled: !fullPlayer.visible && !pages.modalActive && !window.sheetVisible
                onExpandRequested: fullPlayer.open = true
                onPageRequested: (browseId, kind) => Browser.openPage(browseId, kind)
            }
        }

        FullPlayer {
            id: fullPlayer

            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height
            windowRadius: window.windowRadius
            z: 30
            onCollapseRequested: open = false
            onPageRequested: (browseId, kind) => {
                open = false;
                Browser.openPage(browseId, kind);
            }
        }
    }

    ToastHost {
        anchors.right: parent.right
        anchors.rightMargin: Theme.spacing.gutter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.size.playerBar + Theme.spaced(32)
        width: Math.min(Theme.sized(440), parent.width - Theme.spaced(48))
        z: 20
    }

    Connections {
        target: PlaybackController

        function onErrorChanged() {
            Toasts.show(PlaybackController.error, true);
        }

        function onUnavailable(message) {
            Toasts.show(message, true);
        }

        function onRemoteQueueContinued() {
            Toasts.show(qsTr("Picked up where you left off on another device"));
        }
    }

    Connections {
        target: LibraryActions

        function onErrorChanged() {
            Toasts.show(LibraryActions.error, true);
        }

        function onFeedback(message) {
            Toasts.show(message);
        }
    }

    SettingsSheet {
        id: settings

        anchors.fill: parent
        anchors.topMargin: titleBar.height
        onCloseRequested: open = false
    }

    PluginsSheet {
        id: plugins

        anchors.fill: parent
        anchors.topMargin: titleBar.height
        onCloseRequested: open = false
    }

    ReleaseSheet {
        id: release

        anchors.fill: parent
        anchors.topMargin: titleBar.height
        onCloseRequested: open = false
    }

    LoginSheet {
        id: login

        anchors.fill: parent
        onCloseRequested: open = false
    }

    WindowResizeGrips {
        anchors.fill: parent
        z: window.chromeZ + 1
    }

    TrayMenu {}

    Connections {
        target: PluginRegistry

        function onPageRequested(id) {
            plugins.show(id);
        }
    }

    Connections {
        target: Updater

        function onDetailsRequested() {
            settings.open = false;
            release.open = true;
        }
    }

    Connections {
        target: Account

        function onErrorRaised() {
            Toasts.show(Account.error, true);
        }

        function onSignInRequested() {
            login.open = true;
        }

        function onSignInUnavailable() {
            Toasts.show(qsTr("Connect to the internet to sign in."), true);
        }
    }

}
