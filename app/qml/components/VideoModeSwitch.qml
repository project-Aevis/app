import QtQuick
import HtMusic

Item {
    id: root

    property bool video: false
    property real inset: Theme.spaced(4)

    readonly property real segment: (root.width - root.inset * 2) / 2
    readonly property real lane: root.height - root.inset * 2

    signal picked(bool wantsVideo)

    implicitWidth: Theme.sized(72)
    implicitHeight: Theme.sized(28)

    property real reveal: root.video ? 1 : 0

    Behavior on reveal {
        NumberAnimation {
            duration: Theme.duration.spatialFast
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.curve.expressiveFastSpatial
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Theme.darkMode ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.06)
        border.width: 1
        border.color: Theme.darkMode ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.08)
    }

    Rectangle {
        x: root.inset + root.segment * root.reveal
        y: root.inset
        width: root.segment
        height: root.lane
        radius: height / 2
        color: "#FA2D48"
    }

    Row {
        x: root.inset
        y: root.inset

        RippleSurface {
            width: root.segment
            height: root.lane
            rounding: height / 2
            colState: root.video ? Theme.colOnSurface : "#FFFFFF"
            tooltip: Accessible.name
            Accessible.role: Accessible.Button
            Accessible.name: qsTr("Show the artwork")

            Sym {
                anchors.centerIn: parent
                text: "image"
                iconSize: Theme.font.normal
                fill: root.video ? 0 : 1
                color: root.video ? Theme.colOnSurfaceVariant : "#FFFFFF"
            }

            onClicked: root.picked(false)
        }

        RippleSurface {
            width: root.segment
            height: root.lane
            rounding: height / 2
            colState: root.video ? "#FFFFFF" : Theme.colOnSurface
            tooltip: Accessible.name
            Accessible.role: Accessible.Button
            Accessible.name: qsTr("Play the music video")

            Sym {
                anchors.centerIn: parent
                text: "movie"
                iconSize: Theme.font.normal
                fill: root.video ? 1 : 0
                color: root.video ? "#FFFFFF" : Theme.colOnSurfaceVariant
            }

            onClicked: root.picked(true)
        }
    }
}
