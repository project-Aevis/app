import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import HtMusic

Rectangle {
    id: root

    property alias text: input.text
    property bool suggestionsEnabled: false
    property bool pasteEnabled: false
    property bool glass: false
    property int selectedEntry: -1
    property string icon: "search"
    property string placeholder: qsTr("Artists, Songs, Lyrics, and More...")
    property real textPhase: 0

    readonly property bool recalling: input.text.trim().length === 0
    readonly property var entries: !root.suggestionsEnabled ? []
        : root.recalling ? SearchHistory.queries : suggestions.suggestions
    readonly property real expandedHeight: height + (panel.visible ? panel.height + Theme.spaced(8) : 0)
    readonly property real textPresence: 1 - Math.abs(root.textPhase)

    signal accepted(string query)
    signal editingFinished
    signal pasteRequested

    function clearFocus() {
        input.focus = false;
        root.editingFinished();
    }

    function submit(query) {
        if (query.trim().length === 0)
            return;
        input.text = query;
        root.clearFocus();
        root.accepted(query);
    }

    function focusInput() {
        input.forceActiveFocus();
    }

    function follow(query) {
        if (input.activeFocus || query === input.text.trim()) {
            retarget.stop();
            root.textPhase = 0;
            return;
        }
        retarget.query = query;
        retarget.restart();
    }

    implicitHeight: Theme.sized(36)
    radius: height / 2

    scale: input.activeFocus ? 1.01 : (hover.hovered ? 1.006 : 1.0)
    Behavior on scale {
        NumberAnimation {
            duration: Theme.duration.fast
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.curve.expressiveEffects
        }
    }

    color: root.glass
        ? ColorUtils.withAlpha(Theme.colLayer2, 0.55)
        : (Theme.darkMode
            ? (input.activeFocus ? Qt.rgba(1, 1, 1, 0.14)
                : (hover.hovered ? Qt.rgba(1, 1, 1, 0.12)
                : Qt.rgba(1, 1, 1, 0.08)))
            : (input.activeFocus ? "#FFFFFF"
                : (hover.hovered ? Qt.rgba(0, 0, 0, 0.08)
                : Qt.rgba(0, 0, 0, 0.05))))
    border.width: input.activeFocus ? 1.5 : 1
    border.color: input.activeFocus
        ? "#FA2D48"
        : (Theme.darkMode ? Qt.rgba(1.0, 1.0, 1.0, 0.10) : Qt.rgba(0.0, 0.0, 0.0, 0.06))

    Behavior on color {
        ColorAnimation {
            duration: Theme.duration.fast
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.curve.expressiveEffects
        }
    }

    Behavior on border.color {
        ColorAnimation {
            duration: Theme.duration.fast
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.curve.expressiveEffects
        }
    }

    Item {
        id: focusRing

        visible: input.activeFocus || hover.hovered
    }

    AppleIcon {
        id: glyph

        anchors.left: parent.left
        anchors.leftMargin: Theme.spaced(12)
        anchors.verticalCenter: parent.verticalCenter
        visible: root.icon.length > 0
        name: root.icon
        size: Theme.sized(16)
        color: input.activeFocus ? "#FA2D48" : Theme.colOnSurfaceVariant
    }

    TextInput {
        id: input

        anchors.left: glyph.right
        anchors.leftMargin: Theme.spaced(12)
        anchors.right: clear.left
        anchors.rightMargin: Theme.spaced(8)
        anchors.verticalCenter: parent.verticalCenter
        verticalAlignment: TextInput.AlignVCenter
        opacity: root.textPresence
        color: Theme.colOnSurface
        selectionColor: Theme.colPrimary
        selectedTextColor: Theme.colOnPrimary
        selectByMouse: true
        clip: true

        font {
            family: Theme.font.main
            pixelSize: Theme.font.small
            weight: Theme.font.weight
            variableAxes: Theme.font.axes
        }

        transform: Translate {
            x: root.textPhase * 8
        }

        onTextEdited: root.selectedEntry = -1
        onActiveFocusChanged: {
            if (!activeFocus)
                return;
            retarget.stop();
            root.textPhase = 0;
        }
        onAccepted: root.submit(root.selectedEntry >= 0
            ? root.entries[root.selectedEntry] : text)

        Keys.onDownPressed: root.selectedEntry = Math.min(root.entries.length - 1, root.selectedEntry + 1)
        Keys.onUpPressed: root.selectedEntry = Math.max(-1, root.selectedEntry - 1)
        Keys.onEscapePressed: event => {
            event.accepted = root.suggestionsEnabled;
            if (root.suggestionsEnabled)
                root.clearFocus();
        }

        StyledText {
            anchors.verticalCenter: parent.verticalCenter
            visible: input.text.length === 0
            text: root.placeholder
            color: Theme.colInactive
        }
    }

    IconButton {
        id: clear

        anchors.right: paste.left
        anchors.verticalCenter: parent.verticalCenter
        visible: input.text.length > 0
        opacity: root.textPresence
        scale: 0.6 + 0.4 * root.textPresence
        icon: "close"
        Accessible.name: qsTr("Clear search")
        iconSize: Theme.font.normal
        diameter: Theme.sized(36)
        onClicked: input.clear()
    }

    IconButton {
        id: paste

        anchors.right: parent.right
        anchors.rightMargin: Theme.spaced(4)
        anchors.verticalCenter: parent.verticalCenter
        visible: root.pasteEnabled
        icon: "content_paste"
        Accessible.name: qsTr("Open a link from the clipboard")
        iconSize: Theme.font.normal
        diameter: visible ? Theme.sized(36) : 0
        onClicked: {
            root.clearFocus();
            root.pasteRequested();
        }
    }

    SearchSuggestions {
        id: suggestions

        query: root.suggestionsEnabled && input.activeFocus ? input.text : ""
    }

    Popover {
        id: panel

        parent: root
        y: root.height + Theme.spaced(8)
        width: root.width
        focus: false
        closePolicy: Popup.NoAutoClose
        visible: root.suggestionsEnabled && input.activeFocus && root.entries.length > 0

        Column {
            width: panel.columnWidth
            spacing: 0

            Item {
                width: parent.width
                height: Theme.sized(28)
                visible: root.recalling

                StyledText {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spaced(14)
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("RECENT SEARCHES")
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                    font.letterSpacing: 0.6
                    color: Theme.darkMode ? "#8E8E93" : "#86868B"
                }
            }

            Repeater {
                model: root.entries

                delegate: RippleSurface {
                    id: entry

                    required property string modelData
                    required property int index

                    readonly property bool isSelected: root.selectedEntry === entry.index

                    width: parent.width
                    implicitHeight: Theme.sized(42)
                    rounding: Theme.sized(8)
                    colBackground: entry.isSelected
                        ? (Theme.darkMode ? Qt.rgba(250, 45, 72, 0.18) : Qt.rgba(250, 45, 72, 0.10))
                        : "transparent"
                    colState: entry.isSelected ? "#FA2D48" : Theme.colOnSurface

                    AppleIcon {
                        id: cue

                        anchors.left: parent.left
                        anchors.leftMargin: Theme.spaced(14)
                        anchors.verticalCenter: parent.verticalCenter
                        name: root.recalling ? "schedule" : "search"
                        size: Theme.sized(16)
                        color: entry.isSelected ? "#FA2D48" : (Theme.darkMode ? "#8E8E93" : "#86868B")
                    }

                    StyledText {
                        anchors.left: cue.right
                        anchors.leftMargin: Theme.spaced(12)
                        anchors.right: forget.left
                        anchors.rightMargin: Theme.spaced(8)
                        anchors.verticalCenter: parent.verticalCenter
                        text: entry.modelData
                        font.pixelSize: Theme.font.small
                        font.weight: entry.isSelected ? Font.DemiBold : Font.Normal
                        color: entry.isSelected ? (Theme.darkMode ? "#FFFFFF" : "#000000") : Theme.colOnSurface
                        elide: Text.ElideRight
                    }

                    IconButton {
                        id: forget

                        anchors.right: parent.right
                        anchors.rightMargin: Theme.spaced(8)
                        anchors.verticalCenter: parent.verticalCenter
                        visible: root.recalling
                        icon: "close"
                        Accessible.name: qsTr("Remove from search history")
                        iconSize: Theme.sized(14)
                        diameter: visible ? Theme.sized(28) : 0
                        colIcon: Theme.colOnSurfaceVariant
                        onClicked: SearchHistory.forget(entry.modelData)
                    }

                    onClicked: root.submit(entry.modelData)
                }
            }
        }
    }

    HoverHandler {
        id: hover

        cursorShape: Qt.IBeamCursor
    }

    TapHandler {
        onSingleTapped: {
            if (!input.activeFocus)
                root.focusInput();
        }
    }

    TapHandler {
        parent: root.Window.contentItem
        enabled: input.activeFocus

        onPressedChanged: {
            if (!pressed)
                return;
            const local = root.mapFromItem(null, point.scenePosition.x, point.scenePosition.y);
            if (local.x < 0 || local.x > root.width || local.y < 0 || local.y > root.expandedHeight)
                root.clearFocus();
        }
    }

    SequentialAnimation {
        id: retarget

        property string query: ""

        NumberAnimation {
            target: root
            property: "textPhase"
            to: -1
            duration: Theme.duration.exit
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.curve.emphasizedAccel
        }

        ScriptAction {
            script: {
                input.text = retarget.query;
                root.textPhase = 1;
            }
        }

        NumberAnimation {
            target: root
            property: "textPhase"
            to: 0
            duration: Theme.duration.enter
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.curve.emphasizedDecel
        }
    }

    onEntriesChanged: root.selectedEntry = -1
}
