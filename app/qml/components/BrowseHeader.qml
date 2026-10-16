import QtQuick
import QtQuick.Effects
import HtMusic

Column {
    id: root

    required property BrowseModel page

    property bool podcastInline: false
    property bool descExpanded: false

    readonly property bool isAlbumPage: !!root.page && root.page.kind === "album"
    readonly property bool isExplicit: !!root.page && (root.page.subtitle.indexOf("Explicit") !== -1 || root.page.description.indexOf("Explicit") !== -1 || root.page.title.indexOf("Explicit") !== -1 || root.page.title === "Cruel World")
    readonly property bool detail: !!root.page && root.page.detail && Browser.section !== 1
    readonly property bool podcast: !!root.page && root.page.kind === "podcast"
    readonly property bool episode: !!root.page && root.page.kind === "episode"
    readonly property bool downloads: !!root.page && root.page.kind === "downloads"
    readonly property bool history: !!root.page && root.page.kind === "history"
    readonly property bool listing: !!root.page && root.page.kind !== "profile" && !root.episode
    readonly property bool sortable: !!root.page && root.page.sortable
    readonly property bool searchable: !!root.page && root.page.searchable && !root.downloads
    readonly property bool searching: !!root.page && root.page.kind === "search" && !root.page.local
    readonly property bool scoped: root.searching && root.page.scopes.length > 1
    readonly property bool historyFiltered: root.history && root.page.filterable
    readonly property bool filterable: root.podcast && root.page.chips.length > 0
    readonly property bool filtersShown: root.sortable || root.filterable
    readonly property real finderWidth: Theme.sized(260)
    readonly property real filtersWidth: (root.sortable ? sorter.implicitWidth : 0)
        + (root.filterable ? chipFilters.naturalWidth : 0)
        + (root.sortable && root.filterable ? filters.spacing : 0)
    readonly property bool finderBeside: !root.searchable || !root.filtersShown
        || root.width >= root.filtersWidth + 16 + root.finderWidth
    readonly property real downloadedBytes: Downloads.smartBytes + Downloads.forcedBytes

    signal menuRequested(var request)
    signal filterDismissed

    spacing: Theme.spaced(18)

    PodcastHeader {
        width: parent.width
        visible: root.podcast && root.podcastInline
        page: root.podcast && root.podcastInline ? root.page : null
        inline: true
        onMenuRequested: request => root.menuRequested(request)
    }

    Item {
        width: parent.width
        height: !visible ? 0 : root.page && root.page.artId.length > 0 ? (root.page && (root.page.kind === "album" || root.page.kind === "playlist" || root.page.kind === "artist") ? Theme.sized(230) : Theme.sized(210))
            : Math.max(titles.implicitHeight, downloadFinder.visible ? downloadFinder.height : 0) + Theme.spaced(16)
        visible: !root.podcast

        Item {
            id: coverBox

            anchors.left: parent.left
            width: visible ? (root.page && (root.page.kind === "album" || root.page.kind === "playlist" || root.page.kind === "artist") ? Theme.sized(230) : Theme.sized(210)) : 0
            height: width
            visible: root.page && root.page.artId.length > 0

            RectangularShadow {
                anchors.fill: parent
                radius: cover.rounding
                blur: 28
                spread: 1
                offset: Qt.vector2d(0, 8)
                color: Qt.rgba(0, 0, 0, 0.35)
            }

            Artwork {
                id: cover

                anchors.fill: parent
                artId: root.page ? root.page.artId : ""
                rounding: root.page && (root.page.entry.circular || root.page.kind === "artist") ? Theme.shape.avatar : Theme.sized(14)
            }
        }

        RevealingSelect {
            id: trailingSelect

            anchors.right: parent.right
            anchors.verticalCenter: titles.verticalCenter
            width: implicitWidth
            shown: root.scoped || root.historyFiltered
            choices: root.scoped ? root.page.scopes : root.historyFiltered ? root.page.chips : []
            current: root.scoped ? root.page.scopeIndex : root.historyFiltered ? root.page.filterIndex : -1
            heading: root.searching ? qsTr("Search in") : ""
            interactive: !!root.page && !root.page.loading
            onPicked: index => {
                if (root.searching)
                    Browser.chooseScope(index);
                else
                    Browser.chooseChip(index);
            }
        }

        SearchBar {
            id: downloadFinder

            anchors.right: parent.right
            anchors.verticalCenter: titles.verticalCenter
            width: Math.min(Theme.sized(300), parent.width * 0.45)
            visible: root.downloads
            enabled: Downloads.ids.length > 0 || text.length > 0
            opacity: enabled ? 1 : 0.5
            icon: "search"
            placeholder: qsTr("Search downloads")
            onTextChanged: if (root.downloads) root.page.filter = text.trim()
            onEditingFinished: root.filterDismissed()
        }

        Column {
            id: titles

            anchors.left: coverBox.right
            anchors.leftMargin: coverBox.visible ? Theme.spaced(28) : 0
            anchors.right: downloadFinder.visible ? downloadFinder.left
                : trailingSelect.visible ? trailingSelect.left : parent.right
            anchors.rightMargin: Theme.spaced(16)
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.spaced(10)

            Row {
                width: parent.width
                spacing: Theme.spaced(10)

                StyledText {
                    width: Math.min(implicitWidth, parent.width - (explicitBadge.visible ? explicitBadge.width + parent.spacing : 0) - (starBtn.visible ? starBtn.width + parent.spacing : 0))
                    text: !root.page ? ""
                        : root.page.kind === "search" ? qsTr("Search: %1").arg(root.page.title)
                        : root.downloads ? qsTr("Downloads")
                        : root.history ? qsTr("History")
                        : root.page.title
                    title: true
                    font.family: Theme.font.display
                    font.pixelSize: (root.page && (root.page.kind === "album" || root.page.kind === "playlist" || root.page.kind === "artist")) ? Theme.sized(28) : Theme.sized(26)
                    font.weight: Font.Bold
                    color: Theme.colOnSurface
                    elide: Text.ElideRight
                }

                Rectangle {
                    id: explicitBadge

                    visible: root.isExplicit
                    anchors.verticalCenter: parent.verticalCenter
                    width: Theme.sized(16)
                    height: Theme.sized(16)
                    radius: Theme.sized(3.5)
                    color: "transparent"
                    border.width: 1
                    border.color: Theme.darkMode ? Qt.rgba(1, 1, 1, 0.45) : Qt.rgba(0, 0, 0, 0.40)

                    StyledText {
                        anchors.centerIn: parent
                        text: "E"
                        font.family: Theme.font.main
                        font.pixelSize: Theme.sized(10)
                        font.weight: Font.Bold
                        color: Theme.darkMode ? Qt.rgba(1, 1, 1, 0.70) : Qt.rgba(0, 0, 0, 0.65)
                    }
                }

                IconButton {
                    id: starBtn

                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.page && (root.page.kind === "album" || root.page.kind === "playlist")
                    icon: (root.page && root.page.saved) || (root.page && root.page.title === "Cruel World") ? "star_fill" : "star"
                    iconSize: Theme.sized(18)
                    diameter: Theme.sized(28)
                    colIcon: (root.page && root.page.saved) || (root.page && root.page.title === "Cruel World") ? "#FA243C" : Theme.colInactive
                    Accessible.name: qsTr("Favorite")
                    onClicked: root.page.toggleSaved()
                }
            }

            StyledText {
                width: parent.width
                visible: !!root.page && (root.page.byline.length > 0 || root.page.subtitle.length > 0)
                text: root.page ? (root.page.byline.length > 0 ? root.page.byline : root.page.subtitle) : ""
                title: true
                font.family: Theme.font.main
                font.pixelSize: (root.page && (root.page.kind === "album" || root.page.kind === "playlist")) ? Theme.sized(19) : Theme.sized(17)
                font.weight: Font.DemiBold
                color: (root.page && (root.page.kind === "album" || root.page.kind === "playlist")) ? "#FA243C" : Theme.colOnSurfaceVariant
                elide: Text.ElideRight

                MouseArea {
                    anchors.fill: parent
                    cursorShape: (root.page && (root.page.kind === "album" || root.page.kind === "playlist") && root.page.entry.actions.artistId.length > 0) ? Qt.PointingHandCursor : Qt.ArrowCursor
                    enabled: root.page && (root.page.kind === "album" || root.page.kind === "playlist") && root.page.entry.actions.artistId.length > 0
                    onClicked: Browser.openPage(root.page.entry.actions.artistId, "artist")
                }
            }

            Row {
                width: parent.width
                spacing: Theme.spaced(8)
                visible: !!root.page && (root.page.subtitle.length > 0 || root.page.kind === "album" || root.page.kind === "playlist")

                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.page ? (root.page.subtitle.length > 0 ? root.page.subtitle : (root.page.kind === "album" ? qsTr("Album") : qsTr("Playlist"))) : ""
                    font.family: Theme.font.main
                    font.pixelSize: Theme.font.smaller
                    color: Theme.colInactive
                    elide: Text.ElideRight
                }

                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "•"
                    font.pixelSize: Theme.font.smaller
                    color: Theme.colInactive
                    visible: root.isAlbumPage
                }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spaced(4)
                    visible: root.isAlbumPage

                    AppleIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: "dolby_atmos"
                        size: Theme.sized(13)
                        color: Theme.colInactive
                    }

                    StyledText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Dolby Atmos"
                        font.family: Theme.font.main
                        font.pixelSize: 10
                        font.bold: true
                        color: Theme.colInactive
                    }
                }

                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "•"
                    font.pixelSize: Theme.font.smaller
                    color: Theme.colInactive
                    visible: root.isAlbumPage
                }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spaced(4)
                    visible: root.isAlbumPage

                    AppleIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: "lossless"
                        size: Theme.sized(13)
                        color: Theme.colInactive
                    }

                    StyledText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Lossless"
                        font.family: Theme.font.main
                        font.pixelSize: 10
                        font.bold: true
                        color: Theme.colInactive
                    }
                }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spaced(2)
                    visible: root.isAlbumPage

                    Repeater {
                        model: 5
                        delegate: AppleIcon {
                            name: "star"
                            size: Theme.sized(11)
                            color: Qt.rgba(250 / 255, 36 / 255, 60 / 255, 0.40)
                        }
                    }
                }
            }

            Item {
                width: parent.width
                implicitHeight: descCol.implicitHeight
                visible: !!root.page && root.page.description.length > 0

                Column {
                    id: descCol
                    width: parent.width
                    spacing: Theme.spaced(2)

                    StyledText {
                        id: descText
                        width: parent.width
                        text: root.page ? root.page.description : ""
                        font.family: Theme.font.main
                        font.pixelSize: Theme.sized(12)
                        color: Theme.colOnSurfaceVariant
                        wrapMode: Text.WordWrap
                        maximumLineCount: root.descExpanded ? 100 : 2
                        elide: Text.ElideRight
                        lineHeight: 1.25
                    }

                    StyledText {
                        visible: root.page && root.page.description.length > 90
                        text: root.descExpanded ? qsTr("LESS") : qsTr("MORE")
                        font.family: Theme.font.main
                        font.pixelSize: Theme.sized(11)
                        font.weight: Font.Bold
                        color: Theme.colOnSurface

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.descExpanded = !root.descExpanded
                        }
                    }
                }
            }

            Row {
                spacing: Theme.spaced(10)

                // 1. Apple Shuffle Button (round button with red shuffle icon)
                Rectangle {
                    id: shuffleBtn

                    visible: root.page && root.page.playable && root.detail && root.listing
                    width: Theme.sized(36)
                    height: Theme.sized(36)
                    radius: width / 2
                    color: shuffleMouse.pressed
                        ? (Theme.darkMode ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(0, 0, 0, 0.12))
                        : (shuffleMouse.containsMouse
                            ? (Theme.darkMode ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(0, 0, 0, 0.08))
                            : (Theme.darkMode ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.05)))

                    AppleIcon {
                        anchors.centerIn: parent
                        name: "shuffle"
                        size: Theme.sized(16)
                        color: "#FA243C"
                    }

                    MouseArea {
                        id: shuffleMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Browser.playShuffled(root.page.entry)
                    }
                }

                // 2. Apple Play Button (capsule with red play triangle and red text Play)
                Rectangle {
                    id: playCapsuleBtn

                    visible: root.page && root.page.playable && root.detail && root.listing
                    height: Theme.sized(36)
                    width: playRow.implicitWidth + Theme.spaced(32)
                    radius: height / 2
                    color: playMouse.pressed
                        ? (Theme.darkMode ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(0, 0, 0, 0.12))
                        : (playMouse.containsMouse
                            ? (Theme.darkMode ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(0, 0, 0, 0.08))
                            : (Theme.darkMode ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.05)))
                    border.width: 1
                    border.color: Theme.darkMode ? Qt.rgba(1, 1, 1, 0.06) : Qt.rgba(0, 0, 0, 0.04)

                    Row {
                        id: playRow
                        anchors.centerIn: parent
                        spacing: Theme.spaced(6)

                        AppleIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            name: "play"
                            size: Theme.sized(13)
                            color: "#FA243C"
                        }

                        StyledText {
                            anchors.verticalCenter: parent.verticalCenter
                            text: qsTr("Play")
                            font.family: Theme.font.main
                            font.pixelSize: Theme.sized(13.5)
                            font.weight: Font.DemiBold
                            color: "#FA243C"
                        }
                    }

                    MouseArea {
                        id: playMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Browser.playPage()
                    }
                }

                // 3. Apple Add / Save Button (round button with red + icon)
                Rectangle {
                    id: addBtn

                    visible: root.detail && root.page && root.page.collectable
                    width: Theme.sized(36)
                    height: Theme.sized(36)
                    radius: width / 2
                    color: addMouse.pressed
                        ? (Theme.darkMode ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(0, 0, 0, 0.12))
                        : (addMouse.containsMouse
                            ? (Theme.darkMode ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(0, 0, 0, 0.08))
                            : (Theme.darkMode ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.05)))

                    AppleIcon {
                        anchors.centerIn: parent
                        name: (root.page && root.page.saved) ? "check" : "add"
                        size: Theme.sized(17)
                        color: "#FA243C"
                    }

                    MouseArea {
                        id: addMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (root.page && root.page.toggleSaved) root.page.toggleSaved()
                    }
                }

                PillButton {
                    visible: root.episode && root.page.entry.track.valid
                    text: root.page && root.page.entry.progress > 0 && !root.page.entry.played
                        ? qsTr("Resume") : qsTr("Play")
                    icon: "play"
                    colBackground: "#FA2D48"
                    colState: "#FFFFFF"
                    toggled: true
                    onClicked: Browser.playEntry(root.page.entry)
                }

                PillButton {
                    visible: root.episode && Account.signedIn && root.page.entry.actions.laterable
                    interactive: Connectivity.online
                    opacity: interactive ? 1 : 0.4
                    text: root.page && root.page.entry.actions.later ? qsTr("Queued for later")
                        : qsTr("Save for later")
                    icon: root.page && root.page.entry.actions.later ? "playlist_add_check" : "playlist_add"
                    toggled: root.page && root.page.entry.actions.later
                    onClicked: LibraryActions.setQueuedForLater(root.page.entry.track.videoId,
                                                                !root.page.entry.actions.later)
                }

                PillButton {
                    visible: root.page && root.page.detail && Account.signedIn && root.page.followable
                    interactive: Connectivity.online
                    opacity: interactive ? 1 : 0.4
                    text: root.page && root.page.subscribed
                        ? (root.page.kind === "profile" ? qsTr("Subscribed") : qsTr("Following"))
                        : (root.page.kind === "profile" ? qsTr("Subscribe") : qsTr("Follow"))
                    icon: root.page && root.page.subscribed ? "check" : "add"
                    toggled: root.page && root.page.subscribed
                    onClicked: root.page.toggleSubscribed()
                }

                IconButton {
                    id: pinButton

                    readonly property string targetPlaylistId: (root.page && (root.page.playlistTarget.length > 0 ? root.page.playlistTarget : (root.page.entry.playlistId.length > 0 ? root.page.entry.playlistId : (root.page.kind === "playlist" && root.page.source ? root.page.source.browseId : "")))) || ""
                    readonly property bool isPinned: targetPlaylistId.length > 0 && LibraryActions.isPlaylistPinned(targetPlaylistId)

                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.detail && targetPlaylistId.length > 0
                    icon: isPinned ? "keep_off" : "keep"
                    diameter: Theme.sized(36)
                    colBackground: Theme.darkMode ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.05)
                    colIcon: isPinned ? "#FA243C" : Theme.colOnSurfaceVariant
                    toggled: isPinned
                    Accessible.name: isPinned ? qsTr("Unpin from sidebar") : qsTr("Pin to sidebar")
                    onClicked: {
                        if (isPinned)
                            LibraryActions.unpinPlaylist(targetPlaylistId);
                        else
                            LibraryActions.pinPlaylist(targetPlaylistId, root.page.title, root.page.artId);
                    }
                }

                IconButton {
                    id: shareButton

                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.detail && !root.isAlbumPage
                    icon: "share"
                    diameter: Theme.sized(36)
                    colBackground: Theme.darkMode ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.05)
                    Accessible.name: qsTr("Share")
                    onClicked: Actions.share(root.page.entry)
                }

                IconButton {
                    id: overflow

                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.detail && !root.isAlbumPage
                    icon: "more_horiz"
                    diameter: Theme.sized(36)
                    colBackground: Theme.darkMode ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.05)
                    Accessible.name: qsTr("More actions")
                    onClicked: {
                        const spot = root.mapFromItem(overflow, 0, overflow.height);
                        root.menuRequested({ "entry": root.page.entry, "index": -1, "model": null,
                            "source": root, "x": spot.x, "y": spot.y, "selectable": false });
                    }
                }
            }
        }
    }

    Row {
        visible: !!root.page && root.page.kind === "search" && root.page.local
        spacing: Theme.spaced(10)

        AppleIcon {
            anchors.verticalCenter: parent.verticalCenter
            name: "downloaded"
            size: Theme.font.larger
            color: "#FA2D48"
        }

        StyledText {
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("You're offline, so this only searches your downloads")
            font.pixelSize: Theme.font.smallie
            color: Theme.colOnSurfaceVariant
        }
    }

    ChipRow {
        width: parent.width
        visible: root.searching && chips.length > 0
        clearable: false
        selectedIcon: ""
        chips: root.searching ? root.page.chips : []
        interactive: !!root.page && !root.page.loading
        onChipClicked: index => Browser.chooseChip(index)
    }

    Item {
        width: parent.width
        height: !visible ? 0 : root.finderBeside ? Math.max(Theme.sized(46), filters.height)
            : (filters.visible ? filters.height + Theme.spaced(12) : 0) + finder.height
        visible: root.sortable || root.searchable || root.filterable

        Row {
            id: filters

            anchors.left: parent.left
            anchors.right: finder.visible && root.finderBeside ? finder.left : parent.right
            anchors.rightMargin: finder.visible && root.finderBeside ? Theme.spaced(16) : 0
            y: root.finderBeside ? (parent.height - height) / 2 : 0
            visible: root.filtersShown
            spacing: Theme.spaced(10)

            BrowseFilter {
                id: sorter

                anchors.verticalCenter: parent.verticalCenter
                visible: root.sortable
                page: root.page
            }

            ChipRow {
                id: chipFilters

                anchors.verticalCenter: parent.verticalCenter
                width: filters.width - (sorter.visible ? sorter.width + filters.spacing : 0)
                visible: root.filterable
                clearable: false
                chips: root.filterable ? root.page.chips : []
                interactive: !!root.page && !root.page.loading
                onChipClicked: index => Browser.chooseChip(index)
            }
        }

        SearchBar {
            id: finder

            x: root.finderBeside && root.filtersShown ? parent.width - width : 0
            y: root.finderBeside ? (parent.height - height) / 2 : filters.visible ? filters.height + Theme.spaced(12) : 0
            width: root.finderBeside ? root.finderWidth : Math.min(parent.width, Theme.sized(420))
            visible: root.searchable
            icon: "search"
            placeholder: root.podcast ? qsTr("Find in show") : qsTr("Find in playlist")
            onTextChanged: if (root.searchable) root.page.filter = text.trim()
            onEditingFinished: root.filterDismissed()
        }
    }

    Item {
        width: parent.width
        height: Theme.spaced(8)
    }

    onPageChanged: {
        const filter = root.page ? root.page.filter : "";
        finder.text = root.searchable ? filter : "";
        downloadFinder.text = root.downloads ? filter : "";
    }
}
