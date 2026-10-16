import QtQuick
import HtMusic

RippleSurface {
    id: root

    property string title: ""

    readonly property var gradients: [
        ["#E52D27", "#B31217"], // Apple Red
        ["#FF5E3A", "#FF2A68"], // Coral / Hot Pink
        ["#FF9500", "#FF5E3A"], // Orange
        ["#FFCC00", "#FF9500"], // Amber
        ["#34C759", "#30B0C7"], // Emerald
        ["#007AFF", "#5856D6"], // Indigo Blue
        ["#AF52DE", "#5856D6"], // Deep Purple
        ["#FF2D55", "#AF52DE"], // Magenta
        ["#5AC8FA", "#007AFF"], // Sky Blue
        ["#5856D6", "#34C759"], // Electric Mint
    ]

    readonly property int colorIndex: {
        let h = 0;
        for (let i = 0; i < root.title.length; i++) {
            h = (h * 31 + root.title.charCodeAt(i)) & 0x7fffffff;
        }
        return h % gradients.length;
    }

    implicitWidth: Theme.sized(224)
    implicitHeight: Theme.sized(64)
    rounding: Theme.sized(12)
    clip: true

    Rectangle {
        anchors.fill: parent
        radius: parent.rounding

        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: root.gradients[root.colorIndex][0] }
            GradientStop { position: 1.0; color: root.gradients[root.colorIndex][1] }
        }

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: root.hovered ? Qt.rgba(1, 1, 1, 0.14) : "transparent"
        }
    }

    StyledText {
        anchors.left: parent.left
        anchors.leftMargin: Theme.spaced(16)
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.spaced(12)
        anchors.right: parent.right
        anchors.rightMargin: Theme.spaced(14)
        text: root.title
        title: true
        font.pixelSize: Theme.font.small
        font.weight: Font.Bold
        color: "#FFFFFF"
        elide: Text.ElideRight
    }
}
