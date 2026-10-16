import QtQuick
import HtMusic

Item {
    id: root

    implicitWidth: lightsRow.implicitWidth
    implicitHeight: lightsRow.implicitHeight

    readonly property bool windowActive: Window.active
    property bool hovered: hoverArea.containsMouse

    MouseArea {
        id: hoverArea

        anchors.fill: parent
        anchors.margins: -4
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }

    Row {
        id: lightsRow

        spacing: 8
        anchors.centerIn: parent

        // Close (Red)
        Rectangle {
            width: 12
            height: 12
            radius: 6
            color: root.windowActive
                ? (closeArea.pressed ? "#BF4942" : "#FF5F56")
                : (Theme.darkMode ? "#4A4A4E" : "#D1D1D6")
            border.width: 1
            border.color: root.windowActive
                ? (closeArea.pressed ? "#993832" : "#E0443E")
                : (Theme.darkMode ? "#3D3D40" : "#B5B5B5")

            Text {
                anchors.centerIn: parent
                text: "×"
                font.pixelSize: 10
                font.bold: true
                color: "#4D0000"
                opacity: root.hovered && root.windowActive ? 0.85 : 0
            }

            MouseArea {
                id: closeArea
                anchors.fill: parent
                onClicked: WindowChrome.close()
            }
        }

        // Minimize (Yellow)
        Rectangle {
            width: 12
            height: 12
            radius: 6
            color: root.windowActive
                ? (minArea.pressed ? "#C18E22" : "#FFBD2E")
                : (Theme.darkMode ? "#4A4A4E" : "#D1D1D6")
            border.width: 1
            border.color: root.windowActive
                ? (minArea.pressed ? "#99701A" : "#DEA123")
                : (Theme.darkMode ? "#3D3D40" : "#B5B5B5")

            Text {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -1
                text: "−"
                font.pixelSize: 11
                font.bold: true
                color: "#663B00"
                opacity: root.hovered && root.windowActive ? 0.85 : 0
            }

            MouseArea {
                id: minArea
                anchors.fill: parent
                onClicked: WindowChrome.minimize()
            }
        }

        // Maximize / Zoom (Green)
        Rectangle {
            width: 12
            height: 12
            radius: 6
            color: root.windowActive
                ? (zoomArea.pressed ? "#1D9830" : "#27C93F")
                : (Theme.darkMode ? "#4A4A4E" : "#D1D1D6")
            border.width: 1
            border.color: root.windowActive
                ? (zoomArea.pressed ? "#157524" : "#1AAB29")
                : (Theme.darkMode ? "#3D3D40" : "#B5B5B5")

            Text {
                anchors.centerIn: parent
                text: "+"
                font.pixelSize: 10
                font.bold: true
                color: "#0B4D16"
                opacity: root.hovered && root.windowActive ? 0.85 : 0
            }

            MouseArea {
                id: zoomArea
                anchors.fill: parent
                onClicked: WindowChrome.toggleMaximized()
            }
        }
    }
}
