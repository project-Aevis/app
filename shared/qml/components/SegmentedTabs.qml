import QtQuick
import QtQuick.Effects
import HtMusic

Item {
    id: root

    property var labels: []
    property int current: 0
    property bool glass: false
    property real inset: Theme.spaced(4)

    readonly property int count: root.labels.length
    readonly property real segmentWidth: root.count > 0
        ? (root.width - root.inset * 2) / root.count
        : 0
    readonly property real segmentHeight: root.height - root.inset * 2

    implicitWidth: Math.max(Theme.sized(160), root.count * Theme.sized(116))
    implicitHeight: Theme.sized(42)

    Rectangle {
        anchors.fill: parent
        radius: Theme.shape.segmented
        color: Theme.darkMode ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.06)
        border.width: 1
        border.color: Theme.darkMode ? Qt.rgba(1, 1, 1, 0.06) : Qt.rgba(0, 0, 0, 0.04)
    }

    Rectangle {
        x: root.inset + root.segmentWidth * root.current
        y: root.inset
        width: root.segmentWidth
        height: root.segmentHeight
        radius: Theme.shape.segmented - 1
        color: Theme.darkMode ? Qt.rgba(0.24, 0.24, 0.28, 0.95) : "#FFFFFF"
        border.width: 1
        border.color: Theme.darkMode ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.06)

        RectangularShadow {
            anchors.fill: parent
            radius: parent.radius
            blur: 6
            spread: 0
            offset: Qt.vector2d(0, 1)
            color: Qt.rgba(0, 0, 0, Theme.darkMode ? 0.35 : 0.14)
        }

        Behavior on x {
            NumberAnimation {
                duration: Theme.duration.spatialFast
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.curve.expressiveFastSpatial
            }
        }
    }

    Row {
        x: root.inset
        y: root.inset

        Repeater {
            model: root.labels

            delegate: RippleSurface {
                id: segment

                required property string modelData
                required property int index

                readonly property bool selected: root.current === index

                width: root.segmentWidth
                height: root.segmentHeight
                rounding: Theme.shape.segmented - 1
                colState: selected ? (Theme.darkMode ? "#FFFFFF" : "#000000") : Theme.colOnSurface

                StyledText {
                    anchors.centerIn: parent
                    text: segment.modelData
                    title: segment.selected
                    font.weight: segment.selected ? Font.DemiBold : Font.Normal
                    font.pixelSize: Theme.font.smallie
                    color: segment.selected
                        ? (Theme.darkMode ? "#FFFFFF" : "#000000")
                        : (Theme.darkMode ? "#8E8E93" : "#86868B")
                }

                onClicked: root.current = index
            }
        }
    }
}
