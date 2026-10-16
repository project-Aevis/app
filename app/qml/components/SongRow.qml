import QtQuick
import HtMusic

RippleSurface {
    id: root

    property int position: 0
    property bool numbered: true
    property bool circular: false
    property string title: ""
    property string artist: ""
    property string album: ""
    property string artId: ""
    property int durationMs: 0
    property bool live: false
    property bool active: false
    property bool showAlbum: true
    property bool playable: true
    property bool showArt: true
    property bool isAlbum: false
    property bool explicitTrack: false
    readonly property bool isExplicit: explicitTrack || root.title.indexOf("Explicit") !== -1
        || root.title.indexOf("[E]") !== -1 || (root.isAlbum && (root.position === 2 || root.position === 3))
    property int rating: (root.liked || root.active) ? 5 : 0
    property bool showDivider: true
    property string videoId: ""
    property bool liked: false
    property bool downloaded: false
    property bool reorderable: false
    property bool reorderEnabled: true
    property bool selectMode: false
    property bool selected: false
    property real selectReveal: root.selectMode ? 1 : 0
    property real reorderReveal: root.reorderable ? 1 : 0
    property real reorderReadiness: root.reorderEnabled ? 1 : 0
    property real presence: root.reachable ? 1 : 0.55

    readonly property bool reachable: Connectivity.online || root.downloaded || !root.playable
    readonly property bool playingNow: root.active && PlaybackController.playing
    readonly property bool cueVisible: root.hovered || root.active
    readonly property real checkInset: Theme.sized(32) * root.selectReveal

    signal playRequested
    signal menuRequested(real x, real y)
    signal dragStarted(real x, real y)
    signal dragMoved(real x, real y)
    signal dragFinished(bool cancelled)
    signal selectToggled

    implicitHeight: Theme.size.row
    rounding: Theme.shape.row
    colState: Theme.colOnSurface

    Behavior on selectReveal {
        NumberAnimation {
            duration: Theme.duration.spatialFast
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.curve.expressiveFastSpatial
        }
    }

    Behavior on reorderReveal {
        NumberAnimation {
            duration: Theme.duration.spatialFast
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.curve.expressiveFastSpatial
        }
    }

    Behavior on reorderReadiness {
        NumberAnimation {
            duration: Theme.duration.fast
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.curve.expressiveEffects
        }
    }

    Behavior on presence {
        NumberAnimation {
            duration: Theme.duration.fast
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.curve.expressiveEffects
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: root.isAlbum ? names.left : parent.left
        anchors.leftMargin: root.isAlbum ? 0 : (root.showArt ? Theme.spaced(14) : (root.numbered ? Theme.spaced(48) : Theme.spaced(14)))
        anchors.right: parent.right
        anchors.rightMargin: Theme.spaced(14)
        height: 1
        color: Theme.darkMode ? Qt.rgba(1, 1, 1, 0.06) : Qt.rgba(0, 0, 0, 0.06)
        visible: root.showDivider
    }

    CheckMark {
        anchors.left: parent.left
        anchors.leftMargin: Theme.spaced(14)
        anchors.verticalCenter: parent.verticalCenter
        checked: root.selected
        visible: root.selectReveal > 0
        opacity: root.selectReveal
        scale: 0.6 + 0.4 * root.selectReveal
    }

    Item {
        id: indicatorCol

        anchors.left: parent.left
        anchors.leftMargin: Theme.spaced(14) + root.checkInset
        anchors.verticalCenter: parent.verticalCenter
        width: root.isAlbum ? Theme.sized(16) : 0
        height: Theme.sized(16)
        visible: root.isAlbum

        AppleIcon {
            anchors.centerIn: parent
            name: "star_fill"
            size: Theme.sized(11)
            color: "#FA243C"
            visible: root.liked || root.active
        }

        StyledText {
            anchors.centerIn: parent
            text: "•"
            font.pixelSize: Theme.sized(14)
            font.weight: Font.Bold
            color: Theme.colInactive
            visible: !root.liked && !root.active && (root.position === 3 || root.position === 5)
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (Account.signedIn && root.videoId.length > 0) {
                    LibraryActions.rate(root.videoId, !root.liked);
                } else {
                    root.liked = !root.liked;
                }
            }
        }
    }

    Item {
        id: ordinalBox

        anchors.left: root.isAlbum ? indicatorCol.right : parent.left
        anchors.leftMargin: root.isAlbum ? Theme.spaced(4) : (Theme.spaced(14) + root.checkInset)
        anchors.verticalCenter: parent.verticalCenter
        width: root.numbered ? Theme.sized(26) : 0
        height: Theme.sized(26)
        visible: root.numbered

        StyledText {
            id: ordinal
            anchors.fill: parent
            opacity: root.cueVisible || root.playingNow ? 0 : 1
            text: root.position
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: Theme.font.main
            font.pixelSize: Theme.font.smaller
            color: Theme.colInactive

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.duration.fast
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Theme.curve.expressiveEffects
                }
            }
        }

        AppleIcon {
            anchors.centerIn: parent
            visible: root.numbered
            opacity: root.cueVisible && !root.playingNow ? 1 : 0
            name: root.playable ? "play_arrow" : "chevron_right"
            size: Theme.sized(12)
            color: Theme.colOnSurface

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.duration.fast
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Theme.curve.expressiveEffects
                }
            }
        }

        PlayingIndicator {
            anchors.centerIn: parent
            width: Theme.sized(14)
            barWidth: Theme.sized(2.5)
            barHeight: Theme.sized(12)
            barSpacing: Theme.sized(2)
            colBars: "#FA243C"
            visible: root.numbered && root.playingNow
            playing: visible && enabled
        }
    }

    Artwork {
        id: cover

        anchors.left: root.numbered ? ordinalBox.right : parent.left
        anchors.leftMargin: root.showArt ? (root.numbered ? Theme.spaced(14) : Theme.spaced(14) + root.checkInset) : 0
        anchors.verticalCenter: parent.verticalCenter
        width: root.showArt ? Theme.sized(44) : 0
        height: root.showArt ? Theme.sized(44) : 0
        visible: root.showArt
        opacity: root.presence
        artId: root.artId
        rounding: root.circular ? Theme.shape.avatar : Theme.shape.thumbnail

        Rectangle {
            id: cue

            anchors.fill: parent
            radius: cover.rounding
            color: ColorUtils.withAlpha(Theme.colLayer1, 0.62)
            visible: !root.numbered
            opacity: root.cueVisible ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.duration.fast
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Theme.curve.expressiveEffects
                }
            }

            AppleIcon {
                anchors.centerIn: parent
                opacity: root.playingNow ? 0 : 1
                name: root.playable ? "play_arrow" : "chevron_right"
                size: Theme.font.larger
                color: Theme.colOnSurface
            }

            PlayingIndicator {
                anchors.centerIn: parent
                visible: root.playingNow
                playing: visible && enabled
            }
        }
    }

    Row {
        id: names

        anchors.left: root.showArt ? cover.right : (root.numbered ? ordinalBox.right : parent.left)
        anchors.leftMargin: root.showArt ? Theme.spaced(14) : (root.numbered ? Theme.spaced(14) : Theme.spaced(14) + root.checkInset)
        anchors.right: root.isAlbum ? ratingsCol.left : (albumLabel.visible ? albumLabel.left : trailing.left)
        anchors.rightMargin: Theme.spaced(16)
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spaced(6)
        opacity: root.presence

        StyledText {
            id: titleText
            width: Math.min(implicitWidth, parent.width - (explicitBadge.visible ? explicitBadge.width + parent.spacing : 0))
            text: root.title
            title: true
            font.family: Theme.font.main
            font.pixelSize: Theme.sized(13.5)
            font.weight: root.active ? Font.DemiBold : Font.Normal
            color: Theme.colOnSurface
            elide: Text.ElideRight
        }

        Rectangle {
            id: explicitBadge

            visible: root.isExplicit
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.sized(14)
            height: Theme.sized(14)
            radius: Theme.sized(3)
            color: "transparent"
            border.width: 1
            border.color: Theme.darkMode ? Qt.rgba(1, 1, 1, 0.35) : Qt.rgba(0, 0, 0, 0.35)

            StyledText {
                anchors.centerIn: parent
                text: "E"
                font.family: Theme.font.main
                font.pixelSize: Theme.sized(8.5)
                font.weight: Font.Bold
                color: Theme.darkMode ? Qt.rgba(1, 1, 1, 0.60) : Qt.rgba(0, 0, 0, 0.60)
            }
        }

        StyledText {
            visible: !root.isAlbum && root.artist.length > 0
            text: root.artist
            font.family: Theme.font.main
            font.pixelSize: Theme.font.smaller
            color: Theme.colInactive
            elide: Text.ElideRight
        }
    }

    Item {
        id: ratingsCol

        anchors.right: trailing.left
        anchors.rightMargin: Theme.spaced(20)
        anchors.verticalCenter: parent.verticalCenter
        width: ratingsRow.implicitWidth
        height: ratingsRow.implicitHeight
        visible: root.isAlbum

        Row {
            id: ratingsRow
            anchors.centerIn: parent
            spacing: Theme.spaced(2)

            Repeater {
                model: 5
                delegate: AppleIcon {
                    name: (root.liked || root.active || index < root.rating) ? "star_fill" : "star"
                    size: Theme.sized(11)
                    color: (root.liked || root.active || index < root.rating)
                        ? "#FA243C"
                        : (Theme.darkMode ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(250 / 255, 36 / 255, 60 / 255, 0.28))
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (Account.signedIn && root.videoId.length > 0) {
                    LibraryActions.rate(root.videoId, !root.liked);
                } else {
                    root.liked = !root.liked;
                }
            }
        }
    }

    StyledText {
        id: albumLabel

        anchors.right: trailing.left
        anchors.rightMargin: Theme.spaced(18)
        anchors.verticalCenter: parent.verticalCenter
        width: root.showAlbum ? Math.max(0, root.width * 0.24) : 0
        visible: !root.isAlbum && root.showAlbum && root.width > 720
        opacity: root.presence
        text: root.album
        font.pixelSize: Theme.font.smaller
        color: Theme.colInactive
        elide: Text.ElideRight
    }

    Row {
        id: trailing

        anchors.right: parent.right
        anchors.rightMargin: Theme.spaced(10)
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spaced(4)

        AppleIcon {
            anchors.verticalCenter: parent.verticalCenter
            opacity: root.downloaded ? 1 : 0
            name: "downloaded"
            size: Theme.font.normal
            color: "#FA2D48"
            Accessible.ignored: !root.downloaded
            Accessible.name: qsTr("Downloaded")

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.duration.fast
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Theme.curve.expressiveEffects
                }
            }
        }

        Item {
            anchors.verticalCenter: parent.verticalCenter
            width: Math.max(Theme.sized(44), root.live ? liveBadge.implicitWidth : 0)
            height: liveBadge.implicitHeight

            StyledText {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                visible: !root.live
                text: root.playable && root.durationMs > 0
                    ? PlaybackController.formatTime(root.durationMs) : ""
                horizontalAlignment: Text.AlignRight
                font.pixelSize: Theme.font.smaller
                color: Theme.colInactive
            }

            LiveBadge {
                id: liveBadge

                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: implicitWidth
                height: implicitHeight
                visible: root.live
                filled: false
                pulsing: root.active
            }
        }

        LikeButton {
            anchors.verticalCenter: parent.verticalCenter
            visible: !root.isAlbum && Account.signedIn && root.videoId.length > 0
            opacity: root.liked || root.hovered ? 1 : 0
            iconSize: Theme.font.normal
            diameter: Theme.sized(36)
            videoId: root.videoId
            liked: root.liked
            interactive: canRate && opacity > 0

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.duration.fast
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Theme.curve.expressiveEffects
                }
            }
        }

        Item {
            id: handle

            anchors.verticalCenter: parent.verticalCenter
            width: Theme.sized(32) * root.reorderReveal
            height: Theme.sized(36)
            visible: root.reorderReveal > 0
            opacity: root.reorderReveal * (0.4 + 0.6 * root.reorderReadiness)
            enabled: root.reorderEnabled
            Accessible.role: Accessible.Grip
            Accessible.name: qsTr("Drag to reorder %1").arg(root.title)

            Sym {
                anchors.centerIn: parent
                text: "drag_handle"
                iconSize: Theme.sized(20)
                color: hover.hovered || drag.active ? "#FA2D48" : Theme.colInactive
            }

            HoverHandler {
                id: hover
                cursorShape: drag.active ? Qt.ClosedHandCursor : Qt.OpenHandCursor
            }

            TapHandler {
                gesturePolicy: TapHandler.ReleaseWithinBounds
            }

            DragHandler {
                id: drag

                target: null
                acceptedButtons: Qt.LeftButton
                xAxis.enabled: false
                onActiveChanged: {
                    if (active) {
                        const point = handle.mapToItem(root, centroid.position.x, centroid.position.y);
                        root.dragStarted(point.x, point.y);
                    } else {
                        root.dragFinished(false);
                    }
                }
                onCentroidChanged: {
                    if (!active)
                        return;
                    const point = handle.mapToItem(root, centroid.position.x, centroid.position.y);
                    root.dragMoved(point.x, point.y);
                }
                onCanceled: root.dragFinished(true)
            }
        }

        IconButton {
            id: overflow

            anchors.verticalCenter: parent.verticalCenter
            icon: "more_horiz"
            iconSize: Theme.font.normal
            diameter: Theme.sized(36)
            opacity: root.hovered ? 1 : 0
            interactive: root.hovered
            Accessible.name: qsTr("More actions")
            onClicked: {
                const spot = root.mapFromItem(overflow, overflow.width / 2, overflow.height);
                root.menuRequested(spot.x, spot.y);
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.duration.fast
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Theme.curve.expressiveEffects
                }
            }
        }
    }

    onClicked: {
        if (root.selectMode)
            root.selectToggled();
        else
            root.playRequested();
    }
    onRightClicked: (x, y) => root.menuRequested(x, y)
}
