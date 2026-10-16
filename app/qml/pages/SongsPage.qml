import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import HtMusic

Item {
    id: root

    property BrowseModel page: Browser.page
    property real contentReveal: 1
    property bool contentReady: true
    property real loadingReveal: 1
    readonly property bool modalActive: itemMenu.visible

    readonly property real pageWidth: Math.min(root.width, Theme.size.contentMaxWidth)
    readonly property real pageInset: Math.max(0, (root.width - root.pageWidth) / 2)
    readonly property real contentWidth: Math.min(trackList.width, Theme.size.contentMaxWidth)
    readonly property real usableWidth: root.contentWidth - Theme.spacing.bleed * 2

    BrowseContentModel {
        id: contentModel
        page: root.page
        columns: 1
    }

    ItemMenu {
        id: itemMenu
        parent: root
    }

    // Top Header Banner (Apple Music Style Hero)
    Item {
        id: heroHeader

        anchors.top: parent.top
        anchors.topMargin: Theme.spaced(8)
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: root.pageInset + Theme.spacing.bleed
        anchors.rightMargin: root.pageInset + Theme.spacing.bleed
        height: heroRow.implicitHeight + Theme.spaced(24)
        z: 2

        Row {
            id: heroRow

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.spaced(24)

            // Heart / Liked Artwork Capsule
            Item {
                id: coverArt

                width: Theme.sized(140)
                height: Theme.sized(140)
                anchors.verticalCenter: parent.verticalCenter

                RectangularShadow {
                    anchors.fill: parent
                    radius: Theme.sized(16)
                    blur: 24
                    spread: 1
                    offset: Qt.vector2d(0, 8)
                    color: Qt.rgba(0.98, 0.18, 0.28, 0.35)
                }

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.sized(16)
                    gradient: Gradient {
                        orientation: Gradient.TopToBottom
                        GradientStop { position: 0.0; color: "#FF375F" }
                        GradientStop { position: 1.0; color: "#FA2D48" }
                    }

                    AppleIcon {
                        anchors.centerIn: parent
                        name: "heart"
                        size: Theme.sized(64)
                        color: "#FFFFFF"
                    }
                }
            }

            // Info Column
            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: heroRow.width - coverArt.width - heroRow.spacing
                spacing: Theme.spaced(8)

                StyledText {
                    text: qsTr("PLAYLIST")
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    color: "#FA2D48"
                }

                StyledText {
                    text: qsTr("Liked Songs")
                    font.pixelSize: Theme.font.display
                    font.weight: Font.Bold
                    color: Theme.colOnSurface
                    elide: Text.ElideRight
                    width: parent.width
                }

                StyledText {
                    text: Account.signedIn
                        ? qsTr("%n liked song(s) in your library", "", root.page ? root.page.count : 0)
                        : qsTr("Sign in to sync your liked songs from YouTube Music")
                    font.pixelSize: Theme.font.small
                    color: Theme.colOnSurfaceVariant
                }

                Item { width: 1; height: Theme.spaced(4) }

                // Actions Bar
                Row {
                    spacing: Theme.spaced(12)
                    width: parent.width

                    PillButton {
                        text: qsTr("Play")
                        icon: "play"
                        colBackground: "#FA2D48"
                        colState: "#FFFFFF"
                        toggled: true
                        visible: Account.signedIn && !!root.page && root.page.playable
                        onClicked: Browser.playPage()
                    }

                    PillButton {
                        text: qsTr("Shuffle")
                        icon: "shuffle"
                        colBackground: Theme.darkMode ? Qt.rgba(250, 45, 72, 0.16) : Qt.rgba(0, 0, 0, 0.05)
                        colState: "#FA2D48"
                        toggled: false
                        visible: Account.signedIn && !!root.page && root.page.playable
                        onClicked: Browser.playShuffled(root.page.entry)
                    }

                    // Search within liked songs
                    SearchBar {
                        id: songFilter
                        width: Math.min(Theme.sized(260), heroRow.width * 0.35)
                        height: Theme.sized(32)
                        placeholder: qsTr("Find in Songs")
                        visible: Account.signedIn && !!root.page && root.page.count > 0
                        onTextChanged: if (root.page) root.page.filter = text.trim()
                    }
                }
            }
        }
    }

    // Table Column Header (Apple Music table style)
    Item {
        id: tableHeader

        anchors.top: heroHeader.bottom
        anchors.topMargin: Theme.spaced(8)
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: root.pageInset + Theme.spacing.bleed
        anchors.rightMargin: root.pageInset + Theme.spacing.bleed
        height: Theme.sized(32)
        visible: Account.signedIn && !!root.page && root.page.count > 0
        z: 2

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: Theme.darkMode ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.08)
        }

        Row {
            anchors.fill: parent
            anchors.leftMargin: Theme.spaced(14)
            anchors.rightMargin: Theme.spaced(14)
            spacing: Theme.spaced(16)

            StyledText {
                width: Theme.sized(28)
                anchors.verticalCenter: parent.verticalCenter
                text: "#"
                font.pixelSize: 11
                font.weight: Font.DemiBold
                color: Theme.colOnSurfaceVariant
                horizontalAlignment: Text.AlignHCenter
            }

            StyledText {
                width: Math.round(tableHeader.width * 0.38)
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Title")
                font.pixelSize: 11
                font.weight: Font.DemiBold
                color: Theme.colOnSurfaceVariant
            }

            StyledText {
                width: Math.round(tableHeader.width * 0.28)
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Artist")
                font.pixelSize: 11
                font.weight: Font.DemiBold
                color: Theme.colOnSurfaceVariant
            }

            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Time")
                font.pixelSize: 11
                font.weight: Font.DemiBold
                color: Theme.colOnSurfaceVariant
            }
        }
    }

    // Track List
    ListView {
        id: trackList

        anchors.top: tableHeader.visible ? tableHeader.bottom : heroHeader.bottom
        anchors.topMargin: Theme.spaced(8)
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        clip: true
        spacing: Theme.spaced(2)
        boundsBehavior: Flickable.StopAtBounds
        cacheBuffer: 300
        model: root.contentReady && Account.signedIn ? contentModel : null

        ScrollBar.vertical: PageScrollBar {}

        delegate: BrowseRow {
            width: trackList.width
            contentWidth: root.contentWidth
            page: root.page
            cellSize: Theme.sized(200)
            viewport: trackList
            selectMode: false
            onMenuRequested: request => itemMenu.show(request)
        }

        footer: Item {
            width: trackList.width
            height: Theme.sized(80)

            BusySpinner {
                anchors.centerIn: parent
                visible: root.page && root.page.loading && root.page.count > 0
            }
        }

        onAtYEndChanged: {
            if (atYEnd && root.page && root.page.hasMore && !root.page.loading)
                root.page.loadMore();
        }
    }

    // Signed Out State
    Column {
        anchors.centerIn: parent
        spacing: Theme.spaced(14)
        visible: !Account.signedIn

        EmptyState {
            width: Theme.sized(360)
            shown: !Account.signedIn
            icon: "favorite_border"
            title: qsTr("Sign in to see your liked songs")
            caption: qsTr("Your liked songs from YouTube Music will appear here.")
        }

        PillButton {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Sign In")
            icon: "person"
            onClicked: Account.requestSignIn()
        }
    }

    // Empty State (Signed in but no songs)
    EmptyState {
        anchors.centerIn: parent
        shown: Account.signedIn && !!root.page && !root.page.loading && root.page.count === 0
        icon: "heart"
        title: qsTr("No liked songs yet")
        caption: qsTr("Songs you like while listening will be saved here.")
    }

    // Initial Loading State
    LoadingSkeleton {
        anchors.fill: parent
        anchors.topMargin: heroHeader.height + Theme.spaced(16)
        visible: Account.signedIn && !!root.page && root.page.loading && root.page.count === 0
        shape: "list"
    }

    onPageChanged: {
        root.contentReady = false;
        refreshTimer.restart();
    }

    Timer {
        id: refreshTimer
        interval: 50
        onTriggered: root.contentReady = true
    }
}
