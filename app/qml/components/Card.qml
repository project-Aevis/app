import QtQuick
import QtQuick.Effects
import HtMusic

RippleSurface {
    id: root

    property string title: ""
    property string subtitle: ""
    property string artId: ""
    property bool circular: false
    property bool video: false
    property bool playable: false
    property bool pinned: false
    property bool live: false
    property bool active: false
    property real artSize: Theme.size.card

    readonly property real inset: Theme.spacing.cardInset
    readonly property bool playingNow: root.active && PlaybackController.playing
    readonly property bool cueVisible: root.hovered && !root.playingNow

    signal playRequested
    signal menuRequested(real x, real y)

    implicitWidth: root.artSize * (root.video ? 16 / 9 : 1) + root.inset * 2
    implicitHeight: root.artSize + root.inset * 2 + labels.implicitHeight + Theme.spaced(12)
    rounding: Theme.shape.card

    Item {
        id: cover

        x: root.inset
        y: root.hovered ? root.inset - 3 : root.inset
        width: root.artSize * (root.video ? 16 / 9 : 1)
        height: root.artSize
        scale: root.hovered ? 1.035 : 1

        Behavior on y {
            NumberAnimation {
                duration: Theme.duration.fast
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.curve.expressiveEffects
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: Theme.duration.fast
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.curve.expressiveEffects
            }
        }

        RectangularShadow {
            anchors.fill: parent
            radius: art.rounding
            blur: root.hovered ? 20 : 12
            spread: 0.5
            offset: Qt.vector2d(0, root.hovered ? 6 : 4)
            color: Qt.rgba(0, 0, 0, root.hovered ? 0.35 : 0.22)
            visible: !root.circular

            Behavior on blur {
                NumberAnimation {
                    duration: Theme.duration.fast
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Theme.curve.expressiveEffects
                }
            }
            Behavior on offset {
                PropertyAnimation {
                    duration: Theme.duration.fast
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Theme.curve.expressiveEffects
                }
            }
        }

        Artwork {
            id: art

            anchors.fill: parent
            artId: root.artId
            rounding: root.circular ? Theme.shape.avatar : Theme.sized(12)
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: -1
            radius: art.rounding + 1
            color: ColorUtils.withAlpha(Theme.colScrim, 0.42)
            opacity: root.hovered ? 1 : root.active ? 0.5 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.duration.fast
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Theme.curve.expressiveEffects
                }
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.margins: Theme.spaced(8)
            width: Theme.sized(30)
            height: Theme.sized(30)
            radius: Theme.shape.plate
            color: ColorUtils.withAlpha(Theme.colLayer1, 0.85)
            visible: root.pinned

            AppleIcon {
                anchors.centerIn: parent
                name: "favorite"
                size: Theme.font.normal
                color: "#FA2D48"
            }
        }

        LiveBadge {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: Theme.spaced(8)
            width: implicitWidth
            height: implicitHeight
            visible: root.live
            pixelSize: Theme.font.smallest
        }

        Rectangle {
            anchors.centerIn: parent
            width: Theme.sized(54)
            height: Theme.sized(54)
            radius: Theme.shape.playButton
            color: ColorUtils.withAlpha(Theme.colLayer1, 0.85)
            visible: root.active && !root.cueVisible

            PlayingIndicator {
                anchors.centerIn: parent
                barWidth: Theme.sized(4)
                barHeight: Theme.sized(24)
                barSpacing: Theme.sized(4)
                colBars: "#FA2D48"
                playing: root.playingNow
            }
        }

        IconButton {
            id: overflow

            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Theme.spaced(6)
            icon: "more_horiz"
            iconSize: Theme.sized(20)
            diameter: Theme.sized(34)
            colBackground: ColorUtils.withAlpha(Theme.colLayer1, 0.85)
            colIcon: Theme.colOnSurfaceVariant
            opacity: root.hovered ? 1 : 0
            interactive: root.hovered
            Accessible.name: qsTr("More actions")
            onClicked: {
                const spot = root.mapFromItem(overflow, overflow.width, overflow.height);
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

        IconButton {
            x: root.playable || root.circular ? (parent.width - width) / 2 : parent.width - width - Theme.spaced(10)
            y: root.playable || root.circular ? (parent.height - height) / 2 : parent.height - height - Theme.spaced(10)
            icon: root.playingNow ? "pause" : "play_arrow"
            Accessible.name: root.playingNow ? qsTr("Pause") : qsTr("Play")
            iconSize: Theme.sized(20)
            diameter: Theme.sized(44)
            colBackground: "#FA2D48"
            colIcon: "#FFFFFF"
            filled: true
            opacity: root.cueVisible ? 1 : 0
            scale: root.cueVisible ? 1 : 0.7
            interactive: root.cueVisible
            onClicked: root.playRequested()

            RectangularShadow {
                anchors.fill: parent
                radius: width / 2
                blur: 14
                spread: 0
                offset: Qt.vector2d(0, 4)
                color: Qt.rgba(0.98, 0.18, 0.28, 0.45)
                z: -1
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.duration.fast
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Theme.curve.expressiveEffects
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: Theme.duration.fast
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Theme.curve.expressiveFastSpatial
                }
            }
        }
    }

    Column {
        id: labels

        x: root.inset
        y: cover.y + cover.height + Theme.spaced(12)
        width: root.artSize * (root.video ? 16 / 9 : 1)
        spacing: Theme.spaced(2)

        StyledText {
            width: parent.width
            text: root.title
            title: true
            horizontalAlignment: root.circular ? Text.AlignHCenter : Text.AlignLeft
            font.pixelSize: Theme.font.small
            font.weight: Font.DemiBold
            color: root.active ? "#FA2D48" : Theme.colOnSurface
            elide: Text.ElideRight
        }

        StyledText {
            width: parent.width
            visible: root.subtitle.length > 0
            text: root.subtitle
            horizontalAlignment: root.circular ? Text.AlignHCenter : Text.AlignLeft
            font.pixelSize: Theme.font.smaller
            color: Theme.colInactive
            elide: Text.ElideRight
        }
    }

    onRightClicked: (x, y) => root.menuRequested(x, y)
}
