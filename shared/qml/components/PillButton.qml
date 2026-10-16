import QtQuick
import HtMusic

RippleSurface {
    id: root

    property string text: ""
    property string icon: ""
    property bool toggled: false
    property bool ghost: false
    property bool busy: false
    property int iconSize: Theme.font.normal
    property real horizontalPadding: Theme.spaced(16)
    property real leadingPadding: root.horizontalPadding
    property real busyReveal: root.busy ? 1 : 0

    readonly property color colLabel: root.toggled ? "#FFFFFF"
        : Theme.colOnSurface

    implicitWidth: row.implicitWidth + root.leadingPadding + root.horizontalPadding
    implicitHeight: Theme.sized(32)
    rounding: height / 2
    colBackground: root.toggled ? "#FA2D48"
        : root.ghost ? "transparent" : (Theme.darkMode ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.05))
    colState: root.toggled ? "#FFFFFF" : Theme.colOnSurface

    Rectangle {
        anchors.fill: parent
        radius: root.rounding
        color: "transparent"
        border.width: root.toggled ? 0 : 1
        border.color: Theme.darkMode ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.08)
        visible: !root.ghost
    }

    Behavior on busyReveal {
        NumberAnimation {
            duration: Theme.duration.fast
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.curve.expressiveEffects
        }
    }

    Row {
        id: row

        x: root.leadingPadding
        anchors.verticalCenter: parent.verticalCenter
        spacing: root.icon ? Theme.spaced(6) : 0

        AppleIcon {
            id: glyph

            anchors.verticalCenter: parent.verticalCenter
            visible: root.icon.length > 0
            name: root.icon
            size: root.iconSize
            color: root.colLabel
            opacity: 1 - root.busyReveal
            scale: 1 - 0.4 * root.busyReveal
        }

        StyledText {
            anchors.verticalCenter: parent.verticalCenter
            text: root.text
            font.pixelSize: Theme.font.smallie
            font.weight: root.toggled ? Font.DemiBold : Font.Normal
            color: root.colLabel
        }
    }

    BusySpinner {
        x: row.x + glyph.x + (glyph.width - width) / 2
        y: row.y + glyph.y + (glyph.height - height) / 2
        width: root.iconSize + Theme.sized(2)
        height: width
        visible: glyph.visible && root.busyReveal > 0
        opacity: root.busyReveal
        colArc: root.colLabel
    }
}

