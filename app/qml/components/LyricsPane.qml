import QtQuick
import QtQuick.Controls
import HtMusic

Item {
    id: root

    readonly property real emphasisScale: 1.16
    readonly property real scaleReserve: Lyrics.synced ? 1.2 : 1
    readonly property real rightInset: Theme.spaced(24)
    readonly property bool populated: Lyrics.available

    function follow() {
        if (!Lyrics.synced || Lyrics.activeLine < 0 || !root.visible)
            return;

        const origin = lines.contentY;
        glide.stop();
        lines.positionViewAtIndex(Lyrics.activeLine, ListView.Center);
        const target = lines.contentY;
        if (target === origin)
            return;

        lines.contentY = origin;
        glide.from = origin;
        glide.to = target;
        glide.start();
    }

    ErrorState {
        anchors.fill: parent
        size: ErrorState.Pane
        shown: Lyrics.interrupted && !root.populated
        busy: Connectivity.checking
        icon: "cloud_off"
        title: qsTr("Lyrics need a connection")
        caption: qsTr("They show up here as soon as you're back online.")
        onActionTriggered: Lyrics.retry()
    }

    EmptyState {
        anchors.fill: parent
        visible: !root.populated && !Lyrics.loading && !Lyrics.interrupted
        icon: "lyrics"
        title: qsTr("No lyrics")
        caption: PlaybackController.track.valid
            ? qsTr("Lyrics are not available for this track")
            : qsTr("Play a track to see its lyrics")
    }

    BusySpinner {
        anchors.centerIn: parent
        visible: Lyrics.loading && !root.populated
    }

    ListView {
        id: lines

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: source.top
        anchors.bottomMargin: Theme.spaced(8)
        visible: root.populated
        model: Lyrics.lines
        spacing: Theme.spaced(24)
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        topMargin: lines.height * 0.35
        bottomMargin: lines.height * 0.40

        ScrollBar.vertical: PageScrollBar {}

        delegate: Item {
            id: line

            required property string modelData
            required property int index

            readonly property bool spoken: Lyrics.synced && line.index === Lyrics.activeLine
            readonly property int diff: line.index - Lyrics.activeLine
            readonly property real targetOpacity: !Lyrics.synced ? 0.95
                : line.spoken ? 1.0
                : diff > 0 ? (diff === 1 ? 0.55 : diff === 2 ? 0.38 : diff === 3 ? 0.24 : diff === 4 ? 0.14 : 0.06)
                : (diff === -1 ? 0.40 : 0.25)

            width: lines.width
            height: label.implicitHeight

            StyledText {
                id: label

                width: Math.max(1, line.width - root.rightInset)
                renderType: Text.CurveRendering
                text: line.modelData
                title: true
                wrapMode: Text.Wrap
                font.pixelSize: Lyrics.synced ? (line.spoken ? Theme.sized(34) : Theme.sized(30)) : Theme.sized(26)
                font.weight: Font.Bold
                color: "#FFFFFF"
                opacity: line.targetOpacity

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.duration.fast
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Theme.curve.expressiveEffects
                    }
                }

                Behavior on font.pixelSize {
                    NumberAnimation {
                        duration: Theme.duration.spatialFast
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Theme.curve.expressiveFastSpatial
                    }
                }
            }
        }

        ScrollWheel {
            target: lines
        }
    }

    Item {
        id: source

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: attribution.visible ? attribution.contentHeight + Theme.spaced(6) : 0

        StyledText {
            id: attribution

            width: parent.width
            visible: root.populated && Lyrics.source.length > 0
            text: Lyrics.source
            font.pixelSize: Theme.font.smallest
            color: Theme.colInactive
            elide: Text.ElideRight
        }
    }

    NumberAnimation {
        id: glide

        target: lines
        property: "contentY"
        duration: Theme.duration.spatialFast
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Theme.curve.emphasized

        onFinished: lines.returnToBounds()
    }

    Connections {
        target: Lyrics

        function onActiveLineChanged() {
            root.follow();
        }

        function onChanged() {
            glide.stop();
            if (root.populated)
                lines.positionViewAtBeginning();
        }
    }
}
