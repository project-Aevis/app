import QtQuick
import QtQuick.Controls
import HtMusic

Rectangle {
    id: root

    property int current: Browser.section
    property int libraryTab: Browser.libraryTab
    property bool expanded: true
    property real expansion: 1

    signal navigateRequested(int index)
    signal searchRequested(string query)
    signal libraryTabRequested(int tabIndex)
    signal pluginsRequested
    signal settingsRequested
    signal accountRequested
    signal newPlaylistRequested

    readonly property string currentBrowseId: Browser.page && Browser.page.source ? Browser.page.source.browseId : ""

    function getLibraryTabIndex(browseId) {
        if (!Browser.libraryTabs)
            return -1;
        for (let i = 0; i < Browser.libraryTabs.length; ++i) {
            if (Browser.libraryTabs[i].browseId === browseId)
                return i;
        }
        return -1;
    }

    function openLibraryTab(browseId, fallbackIndex) {
        const idx = getLibraryTabIndex(browseId);
        root.navigateRequested(2);
        if (idx !== -1) {
            Browser.showLibraryTab(idx);
        } else {
            Browser.showLibraryTab(fallbackIndex);
        }
    }

    implicitWidth: Theme.sized(225)
    color: Theme.darkMode
        ? Qt.rgba(0.12, 0.12, 0.14, 0.85)
        : Qt.rgba(0.96, 0.96, 0.98, 0.85)


    // Right divider line (macOS 1px split line)
    Rectangle {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: 1
        color: Theme.darkMode ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.07)
    }

    // Top Area: Window Dragging & Traffic Lights
    Item {
        id: titleArea

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: Theme.sized(48)
        z: 2

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

        MacTrafficLights {
            anchors.left: parent.left
            anchors.leftMargin: Theme.spaced(16)
            anchors.verticalCenter: parent.verticalCenter
            visible: WindowChrome.controls
        }
    }

    // Navigation Groups (Scrollable)
    Flickable {
        id: navFlickable

        anchors.top: titleArea.bottom
        anchors.topMargin: Theme.spaced(4)
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: bottomBar.top
        anchors.bottomMargin: Theme.spaced(8)
        contentHeight: navColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ScrollWheel {
            target: navFlickable
        }

        Column {
            id: navColumn

            width: parent.width
            spacing: Theme.spaced(2)

            // TOP NAVIGATION GROUP (Unsectioned)
            NavItem {
                objectName: "search"
                icon: "search"
                label: qsTr("Search")
                selected: !!Browser.page && Browser.page.kind === "search"
                onClicked: {
                    root.navigateRequested(0);
                    root.searchRequested("");
                }
            }

            NavItem {
                objectName: "home"
                icon: "home"
                label: qsTr("Home")
                selected: root.current === 0 && (!Browser.page || Browser.page.kind !== "search")
                onClicked: root.navigateRequested(0)
            }

            NavItem {
                objectName: "browse"
                icon: "new"
                label: qsTr("New")
                selected: root.current === 1
                onClicked: root.navigateRequested(1)
            }

            NavItem {
                objectName: "radio"
                icon: "radio"
                label: qsTr("Radio")
                selected: !!Browser.page && (Browser.page.kind === "radio" || root.currentBrowseId === "FEmusic_radio")
                onClicked: Browser.openPage("FEmusic_radio", "radio")
            }

            Item { width: 1; height: Theme.spaced(12) }

            // SECTION 1: Library
            StyledText {
                text: qsTr("Library")
                font.family: Theme.font.main
                font.pixelSize: 11
                font.weight: Font.DemiBold
                color: Theme.darkMode ? "#8E8E93" : "#86868B"
                leftPadding: Theme.spaced(18)
                bottomPadding: Theme.spaced(4)
            }

            NavItem {
                objectName: "recently_added"
                icon: "recently_added"
                label: qsTr("Recently Added")
                selected: root.current === 2 && (root.currentBrowseId === "FEmusic_library_landing" || (!root.currentBrowseId && root.libraryTab === 0))
                onClicked: root.openLibraryTab("FEmusic_library_landing", 0)
            }

            NavItem {
                objectName: "artists"
                icon: "artists"
                label: qsTr("Artists")
                selected: root.current === 2 && (root.currentBrowseId === "FEmusic_library_corpus_track_artists" || (Browser.libraryTabs[root.libraryTab] && Browser.libraryTabs[root.libraryTab].browseId === "FEmusic_library_corpus_track_artists"))
                onClicked: root.openLibraryTab("FEmusic_library_corpus_track_artists", 3)
            }

            NavItem {
                objectName: "albums"
                icon: "albums"
                label: qsTr("Albums")
                selected: root.current === 2 && (root.currentBrowseId === "FEmusic_liked_albums" || (Browser.libraryTabs[root.libraryTab] && Browser.libraryTabs[root.libraryTab].browseId === "FEmusic_liked_albums"))
                onClicked: root.openLibraryTab("FEmusic_liked_albums", 2)
            }

            NavItem {
                objectName: "songs"
                icon: "songs"
                label: qsTr("Songs")
                selected: root.current === 2 && (root.currentBrowseId === "FEmusic_liked_videos" || (Browser.libraryTabs[root.libraryTab] && Browser.libraryTabs[root.libraryTab].browseId === "FEmusic_liked_videos"))
                onClicked: root.openLibraryTab("FEmusic_liked_videos", 4)
            }

            Item { width: 1; height: Theme.spaced(12) }

            // SECTION 2: Playlists
            Item {
                width: parent.width
                height: Theme.sized(24)

                StyledText {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Playlists")
                    font.family: Theme.font.main
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    color: Theme.darkMode ? "#8E8E93" : "#86868B"
                    leftPadding: Theme.spaced(18)
                }

                Rectangle {
                    id: addPlaylistBtn
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.spaced(12)
                    anchors.verticalCenter: parent.verticalCenter
                    width: Theme.sized(20)
                    height: Theme.sized(20)
                    radius: Theme.sized(4)
                    color: addPlaylistMouse.containsMouse
                        ? (Theme.darkMode ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(0, 0, 0, 0.06))
                        : "transparent"

                    AppleIcon {
                        anchors.centerIn: parent
                        name: "add"
                        size: Theme.sized(12)
                        color: Theme.darkMode ? "#8E8E93" : "#86868B"
                    }

                    MouseArea {
                        id: addPlaylistMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (Account.signedIn)
                                PlaylistTargets.loadAccountPlaylists();
                            pinPopover.open();
                        }
                    }
                }
            }

            NavItem {
                objectName: "all_playlists"
                icon: "playlists"
                label: qsTr("All Playlists")
                selected: root.current === 2 && (root.currentBrowseId === "FEmusic_liked_playlists" || (Browser.libraryTabs[root.libraryTab] && Browser.libraryTabs[root.libraryTab].browseId === "FEmusic_liked_playlists"))
                onClicked: root.openLibraryTab("FEmusic_liked_playlists", 1)
            }

            // Pinned Playlists
            Repeater {
                model: LibraryActions.pinnedPlaylists

                delegate: NavItem {
                    id: pinnedItem
                    required property var modelData
                    required property int index

                    readonly property string targetId: modelData.playlistId || ""
                    readonly property string cleanId: targetId.startsWith("VL") ? targetId.substring(2) : targetId
                    readonly property bool isCurrent: root.current === 2 && (root.currentBrowseId === targetId
                        || root.currentBrowseId === ("VL" + cleanId)
                        || root.currentBrowseId === cleanId)

                    objectName: "pinned_playlist_" + index
                    icon: "playlists"
                    label: modelData.title || qsTr("Playlist")
                    selected: isCurrent
                    trailingIcon: pinnedItem.hovered ? "keep_off" : ""
                    onClicked: {
                        Browser.openPage(pinnedItem.targetId, "playlist");
                    }
                    onTrailingClicked: {
                        LibraryActions.unpinPlaylist(pinnedItem.targetId);
                    }
                }
            }
        }
    }

    // Sidebar Bottom: User Profile & Utility Settings
    Rectangle {
        id: bottomBar

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: Theme.sized(44)
        color: "transparent"

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: ColorUtils.withAlpha(Theme.colOutline, 0.08)
        }

        // Clickable User Profile (Beside Settings & Plugins)
        Rectangle {
            id: userItem

            anchors.left: parent.left
            anchors.leftMargin: Theme.spaced(8)
            anchors.right: actionButtons.left
            anchors.rightMargin: Theme.spaced(4)
            anchors.verticalCenter: parent.verticalCenter
            height: Theme.sized(32)
            radius: Theme.sized(6)
            color: userMouse.pressed
                ? (Theme.darkMode ? ColorUtils.withAlpha("#FFFFFF", 0.10) : ColorUtils.withAlpha("#000000", 0.06))
                : (userMouse.containsMouse
                    ? (Theme.darkMode ? ColorUtils.withAlpha("#FFFFFF", 0.06) : ColorUtils.withAlpha("#000000", 0.035))
                    : "transparent")

            Behavior on color {
                ColorAnimation { duration: Theme.duration.fast }
            }

            Row {
                anchors.fill: parent
                anchors.leftMargin: Theme.spaced(6)
                anchors.rightMargin: Theme.spaced(6)
                spacing: Theme.spaced(8)

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: Theme.sized(20)
                    height: Theme.sized(20)
                    radius: width / 2
                    clip: true
                    color: Theme.colLayer2

                    Artwork {
                        anchors.fill: parent
                        artId: Account.artId
                        visible: Account.signedIn && Account.artId.length > 0
                        rounding: width / 2
                    }

                    Image {
                        anchors.fill: parent
                        source: "qrc:/assets/sidebar/danny_rico.png"
                        fillMode: Image.PreserveAspectCrop
                        visible: !Account.signedIn || Account.artId.length === 0
                    }
                }

                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - Theme.sized(28)
                    text: Account.signedIn ? Account.name : "Danny Rico"
                    font.family: Theme.font.main
                    font.pixelSize: Theme.font.smaller
                    font.weight: Font.Normal
                    color: Theme.darkMode ? "#E5E5EA" : "#1D1D1F"
                    elide: Text.ElideRight
                }
            }

            MouseArea {
                id: userMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.accountRequested()
            }
        }

        Row {
            id: actionButtons

            anchors.right: parent.right
            anchors.rightMargin: Theme.spaced(8)
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.spaced(2)

            IconButton {
                icon: "extension"
                iconSize: Theme.sized(17)
                Accessible.name: qsTr("Plugins")
                onClicked: root.pluginsRequested()
            }

            IconButton {
                icon: "settings"
                iconSize: Theme.sized(17)
                Accessible.name: qsTr("Settings")
                onClicked: root.settingsRequested()
            }
        }
    }

    Popover {
        id: pinPopover

        parent: root
        x: Theme.sized(12)
        y: Theme.sized(160)
        width: Theme.sized(260)

        Column {
            width: parent.width
            spacing: Theme.spaced(8)

            Item {
                width: parent.width
                height: Theme.sized(28)

                StyledText {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Pin Playlists to Sidebar")
                    font.family: Theme.font.main
                    font.pixelSize: Theme.font.smaller
                    font.weight: Font.DemiBold
                    color: Theme.colOnSurface
                }

                IconButton {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "close"
                    diameter: Theme.sized(24)
                    onClicked: pinPopover.close()
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.colOutlineVariant
            }

            // If not signed in
            Column {
                width: parent.width
                spacing: Theme.spaced(8)
                visible: !Account.signedIn

                StyledText {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    text: qsTr("Sign in to your account to view and pin your playlists.")
                    font.family: Theme.font.main
                    font.pixelSize: Theme.font.smallie
                    color: Theme.colInactive
                }

                PillButton {
                    text: qsTr("Sign In")
                    onClicked: {
                        pinPopover.close();
                        root.accountRequested();
                    }
                }
            }

            // Loading state
            Item {
                width: parent.width
                height: Theme.sized(60)
                visible: Account.signedIn && PlaylistTargets.loading

                BusySpinner {
                    anchors.centerIn: parent
                }
            }

            // Playlist targets list
            Flickable {
                id: targetsFlickable
                width: parent.width
                height: Math.min(Theme.sized(220), targetsCol.implicitHeight)
                contentHeight: targetsCol.implicitHeight
                clip: true
                visible: Account.signedIn && !PlaylistTargets.loading && PlaylistTargets.count > 0

                Column {
                    id: targetsCol
                    width: parent.width
                    spacing: Theme.spaced(4)

                    Repeater {
                        model: PlaylistTargets

                        delegate: Rectangle {
                            id: targetRow
                            required property string targetTitle
                            required property string targetSubtitle
                            required property string targetPlaylistId
                            required property string targetArtId
                            required property int index

                            readonly property bool isPinned: LibraryActions.isPlaylistPinned(targetPlaylistId)

                            width: targetsCol.width
                            height: Theme.sized(36)
                            radius: Theme.sized(6)
                            color: targetMouse.containsMouse
                                ? (Theme.darkMode ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.04))
                                : "transparent"

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: Theme.spaced(6)
                                anchors.rightMargin: Theme.spaced(6)
                                spacing: Theme.spaced(8)

                                AppleIcon {
                                    anchors.verticalCenter: parent.verticalCenter
                                    name: targetRow.isPinned ? "keep" : "playlists"
                                    size: Theme.sized(16)
                                    color: targetRow.isPinned ? "#FA243C" : Theme.colInactive
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - Theme.sized(54)
                                    spacing: 1

                                    StyledText {
                                        width: parent.width
                                        text: targetRow.targetTitle
                                        font.family: Theme.font.main
                                        font.pixelSize: Theme.font.smaller
                                        font.weight: targetRow.isPinned ? Font.Medium : Font.Normal
                                        color: targetRow.isPinned ? (Theme.darkMode ? "#FFFFFF" : "#1D1D1F") : Theme.colOnSurface
                                        elide: Text.ElideRight
                                    }

                                    StyledText {
                                        width: parent.width
                                        text: targetRow.targetSubtitle
                                        font.family: Theme.font.main
                                        font.pixelSize: 10
                                        color: Theme.colInactive
                                        elide: Text.ElideRight
                                        visible: text.length > 0
                                    }
                                }

                                AppleIcon {
                                    anchors.verticalCenter: parent.verticalCenter
                                    name: targetRow.isPinned ? "check" : "add"
                                    size: Theme.sized(14)
                                    color: targetRow.isPinned ? "#FA243C" : Theme.colInactive
                                }
                            }

                            MouseArea {
                                id: targetMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    LibraryActions.togglePinPlaylist(targetRow.targetPlaylistId, targetRow.targetTitle, targetRow.targetArtId);
                                }
                            }
                        }
                    }
                }
            }

            // If empty
            StyledText {
                width: parent.width
                visible: Account.signedIn && !PlaylistTargets.loading && PlaylistTargets.count === 0
                text: qsTr("No playlists found in your account.")
                font.family: Theme.font.main
                font.pixelSize: Theme.font.smallie
                color: Theme.colInactive
            }
        }
    }
}
