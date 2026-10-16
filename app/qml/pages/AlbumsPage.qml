import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import HtMusic

Item {
    id: root

    property BrowseModel page: Browser.page
    property real contentReveal: 1
    property bool contentReady: true
    readonly property bool modalActive: itemMenu.visible

    readonly property real pageWidth: Math.min(root.width, Theme.size.contentMaxWidth)
    readonly property real pageInset: Math.max(0, (root.width - root.pageWidth) / 2)
    readonly property real contentWidth: Math.min(albumList.width, Theme.size.contentMaxWidth)
    readonly property real cellSize: Math.min(Theme.sized(210),
        (root.contentWidth - Theme.spacing.bleed * 2) / contentModel.columns - Theme.spaced(20))

    BrowseContentModel {
        id: contentModel
        page: root.page
        columns: Math.max(2, Math.floor((root.contentWidth - Theme.spacing.bleed * 2) / (Theme.size.card + Theme.spaced(24))))
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
        height: headerCol.implicitHeight + Theme.spaced(20)
        z: 2

        Column {
            id: headerCol

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.spaced(12)

            Row {
                width: parent.width
                spacing: Theme.spaced(16)

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - (finder.visible ? finder.width + Theme.spaced(16) : 0)
                    spacing: Theme.spaced(4)

                    StyledText {
                        text: qsTr("LIBRARY")
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: "#FA2D48"
                    }

                    StyledText {
                        text: qsTr("Albums")
                        font.pixelSize: Theme.font.display
                        font.weight: Font.Bold
                        color: Theme.colOnSurface
                    }

                    StyledText {
                        text: Account.signedIn
                            ? qsTr("%n album(s) saved in your library", "", root.page ? root.page.count : 0)
                            : qsTr("Sign in to sync your saved albums from YouTube Music")
                        font.pixelSize: Theme.font.small
                        color: Theme.colOnSurfaceVariant
                    }
                }

                // Search Filter inside albums
                SearchBar {
                    id: finder
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.min(Theme.sized(260), parent.width * 0.35)
                    height: Theme.sized(32)
                    placeholder: qsTr("Find in Albums")
                    visible: Account.signedIn && !!root.page && root.page.count > 0
                    onTextChanged: if (root.page) root.page.filter = text.trim()
                }
            }

            // Inset Divider Line
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.darkMode ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.08)
            }
        }
    }

    // Albums Grid List
    ListView {
        id: albumList

        anchors.top: heroHeader.bottom
        anchors.topMargin: Theme.spaced(8)
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        clip: true
        spacing: Theme.spaced(12)
        boundsBehavior: Flickable.StopAtBounds
        cacheBuffer: 300
        model: root.contentReady && Account.signedIn ? contentModel : null

        ScrollBar.vertical: PageScrollBar {}

        delegate: BrowseRow {
            width: albumList.width
            contentWidth: root.contentWidth
            page: root.page
            cellSize: root.cellSize
            viewport: albumList
            selectMode: false
            onMenuRequested: request => itemMenu.show(request)
        }

        footer: Item {
            width: albumList.width
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
            icon: "album"
            title: qsTr("Sign in to see your saved albums")
            caption: qsTr("Your saved albums from YouTube Music will appear here.")
        }

        PillButton {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Sign In")
            icon: "person"
            onClicked: Account.requestSignIn()
        }
    }

    // Empty State (Signed in but no albums)
    EmptyState {
        anchors.centerIn: parent
        shown: Account.signedIn && !!root.page && !root.page.loading && root.page.count === 0
        icon: "album"
        title: qsTr("No saved albums yet")
        caption: qsTr("Albums you save will appear here in your library.")
    }

    // Initial Loading State
    LoadingSkeleton {
        anchors.fill: parent
        anchors.topMargin: heroHeader.height + Theme.spaced(16)
        visible: Account.signedIn && !!root.page && root.page.loading && root.page.count === 0
        shape: "grid"
        columns: contentModel.columns
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
