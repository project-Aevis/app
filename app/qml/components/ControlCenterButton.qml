import QtQuick
import QtQuick.Effects
import HtMusic

Item {
    id: root

    readonly property bool busy: ControlCenter.status === ControlCenter.Busy
    readonly property bool alert: ControlCenter.status === ControlCenter.Alert
    readonly property real lift: 3

    property real busyReveal: root.busy ? 1 : 0
    property real alertReveal: root.alert ? 1 : 0
    property real barFill: ControlCenter.progress
    property real dotPop: 1

    implicitWidth: Theme.sized(36)
    implicitHeight: Theme.sized(36)

    Behavior on busyReveal {
        NumberAnimation {
            duration: Theme.duration.spatialFast
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.curve.expressiveFastSpatial
        }
    }

    Behavior on alertReveal {
        NumberAnimation {
            duration: Theme.duration.spatialFast
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.curve.expressiveFastSpatial
        }
    }

    Behavior on barFill {
        NumberAnimation {
            duration: Theme.duration.fast
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.curve.decelerate
        }
    }

    Rectangle {
        id: bg

        anchors.fill: parent
        radius: width / 2
        color: Theme.darkMode
            ? (mouseArea.pressed ? Qt.rgba(1, 1, 1, 0.05)
                : (mouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.14)
                : Qt.rgba(1, 1, 1, 0.08)))
            : (mouseArea.pressed ? Qt.rgba(0, 0, 0, 0.12)
                : (mouseArea.containsMouse ? Qt.rgba(0, 0, 0, 0.09)
                : Qt.rgba(0, 0, 0, 0.05)))
        border.width: 1
        border.color: Theme.darkMode
            ? Qt.rgba(1.0, 1.0, 1.0, 0.10)
            : Qt.rgba(0.0, 0.0, 0.0, 0.06)

        scale: mouseArea.pressed ? 0.92 : (mouseArea.containsMouse ? 1.05 : 1.0)
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

        Item {
            id: glyphs

            anchors.fill: parent

            AppleIcon {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -root.lift * root.busyReveal
                name: "tune"
                size: Theme.sized(16)
                color: Theme.colOnSurface
                opacity: 1 - root.busyReveal
                scale: 1 - 0.2 * root.busyReveal
            }

            AppleIcon {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -root.lift * root.busyReveal
                name: "download"
                size: Theme.sized(15)
                color: Theme.colPrimary
                opacity: root.busyReveal
                scale: 0.8 + 0.2 * root.busyReveal
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                y: parent.height / 2 + Theme.sized(6)
                width: Theme.sized(16)
                height: Theme.sized(2.5)
                radius: 1.5
                color: ColorUtils.withAlpha(Theme.colOnSurfaceVariant, 0.28)
                opacity: root.busyReveal
                scale: 0.6 + 0.4 * root.busyReveal

                Rectangle {
                    width: parent.width * Math.max(0, Math.min(1, root.barFill))
                    height: parent.height
                    radius: parent.radius
                    color: Theme.colPrimary
                }
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: panel.toggle()
        }
    }

    Rectangle {
        x: root.width - width - Theme.spaced(2)
        y: Theme.spaced(2)
        width: Theme.sized(7)
        height: Theme.sized(7)
        radius: width / 2
        color: "#FA2D48"
        border.width: 1
        border.color: "#FFFFFF"
        opacity: root.alertReveal
        scale: root.alertReveal * root.dotPop
    }

    SequentialAnimation {
        id: pop

        NumberAnimation {
            target: root
            property: "dotPop"
            to: 1.6
            duration: Math.round(Theme.duration.spatialFast * 0.4)
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.curve.decelerate
        }
        NumberAnimation {
            target: root
            property: "dotPop"
            to: 1
            duration: Theme.duration.spatialFast
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.curve.expressiveFastSpatial
        }
    }

    Connections {
        target: ControlCenter

        function onArrived() {
            pop.restart();
        }
    }

    Connections {
        target: PluginRegistry

        function onPageRequested(id) {
            panel.close();
        }
    }

    Connections {
        target: Updater

        function onDetailsRequested() {
            panel.close();
        }
    }

    ControlCenterPanel {
        id: panel

        parent: root
        x: root.width - width
        y: root.height + Theme.spaced(10)
        anchorX: (panel.width - root.width / 2) / panel.width
    }
}
