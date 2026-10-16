import QtQuick
import HtMusic

Item {
    id: root

    property string icon: ""
    property string label: ""
    property bool selected: false
    property real expansion: 1
    property color accentColor: "#FA243C"
    property real indent: 0
    property string thumbnail: ""
    property string trailingIcon: ""
    property bool showChevron: false
    property bool chevronExpanded: true
    readonly property alias hovered: pill.hovered

    signal clicked
    signal chevronClicked
    signal trailingClicked

    implicitHeight: Theme.sized(31)
    implicitWidth: parent ? parent.width : Theme.sized(215)

    Rectangle {
        id: pill

        anchors.fill: parent
        anchors.leftMargin: Theme.spaced(8) + root.indent
        anchors.rightMargin: Theme.spaced(8)
        radius: Theme.sized(7.5)

        readonly property bool hovered: mouseArea.containsMouse
        readonly property bool pressed: mouseArea.pressed

        color: root.selected
            ? (Theme.darkMode ? ColorUtils.withAlpha("#FFFFFF", 0.14) : ColorUtils.withAlpha("#000000", 0.06))
            : (pressed
                ? (Theme.darkMode ? ColorUtils.withAlpha("#FFFFFF", 0.10) : ColorUtils.withAlpha("#000000", 0.06))
                : (hovered
                    ? (Theme.darkMode ? ColorUtils.withAlpha("#FFFFFF", 0.06) : ColorUtils.withAlpha("#000000", 0.035))
                    : "transparent"))

        Behavior on color {
            ColorAnimation {
                duration: Theme.duration.fast
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.curve.expressiveEffects
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.clicked()
        }

        Row {
            anchors.fill: parent
            anchors.leftMargin: Theme.spaced(8)
            anchors.rightMargin: Theme.spaced(8)
            spacing: Theme.spaced(8)

            Item {
                id: chevronBox
                anchors.verticalCenter: parent.verticalCenter
                width: root.showChevron ? Theme.sized(10) : 0
                height: Theme.sized(10)
                visible: root.showChevron

                AppleIcon {
                    anchors.centerIn: parent
                    name: "chevron_down"
                    size: Theme.sized(9)
                    color: Theme.colInactive
                    rotation: root.chevronExpanded ? 0 : -90
                    Behavior on rotation {
                        NumberAnimation { duration: 150 }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -4
                    onClicked: root.chevronClicked()
                }
            }

            Item {
                id: iconBox
                anchors.verticalCenter: parent.verticalCenter
                width: Theme.sized(18)
                height: Theme.sized(18)
                visible: root.thumbnail.length > 0 || root.icon.length > 0

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.sized(4.5)
                    clip: true
                    visible: root.thumbnail.length > 0
                    color: Theme.colLayer2

                    Image {
                        anchors.fill: parent
                        source: root.thumbnail
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        sourceSize: Qt.size(36, 36)
                    }
                }

                AppleIcon {
                    anchors.centerIn: parent
                    name: root.icon
                    size: Theme.sized(17)
                    color: root.accentColor
                    visible: root.thumbnail.length === 0 && root.icon.length > 0
                }
            }

            StyledText {
                id: textLabel
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - (chevronBox.visible ? chevronBox.width + parent.spacing : 0)
                    - (iconBox.visible ? iconBox.width + parent.spacing : 0)
                    - (trailingBox.visible ? trailingBox.width + parent.spacing : 0)
                text: root.label
                font.family: Theme.font.main
                font.pixelSize: Theme.font.smaller
                font.weight: root.selected ? Font.Medium : Font.Normal
                color: root.selected
                    ? (Theme.darkMode ? "#FFFFFF" : "#1D1D1F")
                    : (Theme.darkMode ? "#E5E5EA" : "#1D1D1F")
                elide: Text.ElideRight
            }

            Item {
                id: trailingBox
                anchors.verticalCenter: parent.verticalCenter
                width: root.trailingIcon.length > 0 ? Theme.sized(16) : 0
                height: Theme.sized(16)
                visible: root.trailingIcon.length > 0

                AppleIcon {
                    anchors.centerIn: parent
                    name: root.trailingIcon
                    size: Theme.sized(14)
                    color: Theme.colInactive
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -4
                    cursorShape: Qt.PointingHandCursor
                    visible: root.trailingIcon.length > 0
                    onClicked: root.trailingClicked()
                }
            }
        }
    }
}
