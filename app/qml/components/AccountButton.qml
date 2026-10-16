import QtQuick
import QtQuick.Effects
import HtMusic

Item {
    id: root

    property bool glass: false

    readonly property string label: Account.name.length > 0 ? Account.name : qsTr("Account")

    signal historyRequested
    signal settingsRequested

    implicitWidth: surface.implicitWidth
    implicitHeight: Theme.sized(36)

    RippleSurface {
        id: surface

        tooltip: Account.signedIn ? qsTr("Account options") : qsTr("Sign in")

        implicitWidth: row.implicitWidth + Theme.spaced(24)
        anchors.fill: parent
        rounding: height / 2
        scale: surface.pressed ? 0.94 : (surface.hovered ? 1.04 : 1.0)
        Behavior on scale {
            NumberAnimation {
                duration: Theme.duration.fast
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.curve.expressiveEffects
            }
        }
        colBackground: root.glass
            ? ColorUtils.withAlpha(Theme.colLayer2, 0.5)
            : (Account.signedIn
                ? (Theme.darkMode
                    ? (surface.pressed ? Qt.rgba(1, 1, 1, 0.05) : (surface.hovered ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(1, 1, 1, 0.08)))
                    : (surface.pressed ? Qt.rgba(0, 0, 0, 0.12) : (surface.hovered ? Qt.rgba(0, 0, 0, 0.09) : Qt.rgba(0, 0, 0, 0.05))))
                : "#FA2D48")
        colState: Account.signedIn ? Theme.colOnSurface : "#FFFFFF"

        Rectangle {
            anchors.fill: parent
            radius: surface.rounding
            color: "transparent"
            border.width: 1
            border.color: Account.signedIn
                ? (Theme.darkMode ? Qt.rgba(1.0, 1.0, 1.0, 0.10) : Qt.rgba(0.0, 0.0, 0.0, 0.06))
                : "transparent"
        }

        Row {
            id: row

            anchors.centerIn: parent
            spacing: Theme.spaced(8)

            Artwork {
                anchors.verticalCenter: parent.verticalCenter
                width: Theme.sized(22)
                height: Theme.sized(22)
                visible: Account.signedIn && Account.artId.length > 0
                artId: Account.artId
                rounding: Theme.shape.avatar
            }

            AppleIcon {
                anchors.verticalCenter: parent.verticalCenter
                visible: !Account.signedIn || Account.artId.length === 0
                name: "person"
                size: Theme.sized(16)
                color: Account.signedIn ? Theme.colOnSurfaceVariant : "#FFFFFF"
            }

            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: Account.busy ? qsTr("Signing in...")
                    : Account.signedIn ? root.label
                    : Account.status === Account.Expired ? qsTr("Sign in again")
                    : qsTr("Sign in")
                title: !Account.signedIn
                elide: Text.ElideRight
                maximumLineCount: 1
                font.pixelSize: Theme.font.smallie
                font.weight: Account.signedIn ? Font.Normal : Font.DemiBold
                color: Account.signedIn ? Theme.colOnSurface : "#FFFFFF"
            }
        }

        onClicked: {
            if (Account.signedIn)
                menu.toggle();
            else
                Account.requestSignIn();
        }
    }

    PopupMenu {
        id: menu

        parent: root
        width: Theme.sized(268)
        x: root.width - width
        y: root.height + Theme.spaced(8)
        anchorX: (menu.width - root.width / 2) / menu.width
        itemHeight: Theme.sized(40)
        actions: [
            { "icon": "settings", "text": qsTr("Settings") },
            { "icon": "history", "text": qsTr("History") },
            { "icon": "logout", "text": qsTr("Sign out"), "destructive": true }
        ]

        header: Component {
            Item {
                implicitHeight: Theme.sized(44)

                Artwork {
                    id: avatar

                    anchors.left: parent.left
                    anchors.leftMargin: menu.itemPadding
                    anchors.verticalCenter: parent.verticalCenter
                    width: Theme.sized(44)
                    height: Theme.sized(44)
                    visible: Account.artId.length > 0
                    artId: Account.artId
                    rounding: Theme.shape.avatar
                }

                Rectangle {
                    anchors.fill: avatar
                    radius: Theme.shape.avatar
                    color: Theme.colLayer4
                    visible: !avatar.visible

                    AppleIcon {
                        anchors.centerIn: parent
                        name: "person"
                        size: Theme.sized(24)
                        color: Theme.colOnSurfaceVariant
                    }
                }

                Column {
                    anchors.left: avatar.right
                    anchors.leftMargin: Theme.spaced(12)
                    anchors.right: parent.right
                    anchors.rightMargin: menu.itemPadding
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spaced(2)

                    StyledText {
                        width: parent.width
                        text: root.label
                        title: true
                        elide: Text.ElideRight
                    }

                    StyledText {
                        width: parent.width
                        visible: Account.handle.length > 0
                        text: Account.handle
                        elide: Text.ElideRight
                        font.pixelSize: Theme.font.smaller
                        color: Theme.colOnSurfaceVariant
                    }
                }
            }
        }

        onTriggered: index => {
            if (index === 0)
                root.settingsRequested();
            else if (index === 1)
                root.historyRequested();
            else
                Account.signOut();
        }
    }
}
