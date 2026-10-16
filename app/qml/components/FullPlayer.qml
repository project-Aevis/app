import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import HtMusic

Rectangle {
    id: root

    property bool open: false
    property int pane: 0
    property real podcastReveal: root.episode ? 1 : 0

    readonly property alias backgroundItem: ambience
    readonly property bool episode: PlaybackController.episode
    property real windowRadius: 16

    readonly property bool lyricsShown: !root.episode && root.pane === 0
    readonly property bool queueShown: root.episode ? root.pane === 0 : root.pane === 1

    signal collapseRequested
    signal pageRequested(string browseId, string kind)

    y: root.height
    visible: root.open || y < height
    radius: root.windowRadius
    color: "#000000"

    layer.enabled: !WindowState.maximized
    layer.smooth: true
    layer.effect: RoundedMask {
        rounding: root.windowRadius
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onWheel: event => event.accepted = true
    }

    TrackSwitch {
        id: switcher

        travel: 64
        dip: 0.08
    }

    states: State {
        name: "open"
        when: root.open

        PropertyChanges {
            target: root
            y: 0
        }
    }

    transitions: [
        Transition {
            to: "open"
            NumberAnimation {
                property: "y"
                duration: Theme.duration.sheetEnter
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.curve.emphasized
            }
        },
        Transition {
            from: "open"
            NumberAnimation {
                property: "y"
                duration: Theme.duration.sheetExit
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.curve.emphasized
            }
        }
    ]

    // Vivid Ambient Artwork Background
    Item {
        id: ambience

        anchors.fill: parent
        layer.enabled: true
        layer.effect: RoundedMask {
            rounding: root.radius
        }

        AmbientArt {
            anchors.fill: parent
            artId: switcher.track.artId
            opacity: 1.0
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.05)
        }
    }

    // Top Area: Window Dragging, Traffic Lights, and Apple Glass Capsules
    Item {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: Theme.sized(56)
        z: 15

        DragHandler {
            target: null
            onActiveChanged: {
                if (active)
                    WindowChrome.startMove();
            }
        }

        TapHandler {
            gesturePolicy: TapHandler.DragThreshold
            onDoubleTapped: WindowChrome.toggleMaximized()
        }

        MacTrafficLights {
            id: trafficLights
            anchors.left: parent.left
            anchors.leftMargin: Theme.spaced(16)
            anchors.verticalCenter: parent.verticalCenter
            visible: WindowChrome.controls
        }

        // Top-Left Capsule: [ X | PiP ]
        Rectangle {
            anchors.left: trafficLights.visible ? trafficLights.right : parent.left
            anchors.leftMargin: trafficLights.visible ? Theme.spaced(16) : Theme.spaced(20)
            anchors.verticalCenter: parent.verticalCenter
            height: Theme.sized(32)
            width: rowTopLeft.width + Theme.spaced(16)
            radius: height / 2
            color: Qt.rgba(0, 0, 0, 0.25)
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.16)

            Row {
                id: rowTopLeft
                anchors.centerIn: parent
                spacing: Theme.spaced(6)

                IconButton {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "close"
                    iconSize: Theme.sized(14)
                    diameter: Theme.sized(24)
                    colIcon: "#FFFFFF"
                    colBackground: "transparent"
                    Accessible.name: qsTr("Close Now Playing")
                    onClicked: root.collapseRequested()
                }

                IconButton {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "pip"
                    iconSize: Theme.sized(15)
                    diameter: Theme.sized(24)
                    colIcon: "#FFFFFF"
                    colBackground: "transparent"
                    Accessible.name: qsTr("Picture in Picture")
                    onClicked: root.collapseRequested()
                }
            }
        }

        // Top-Right Capsule: [ AirPlay | Volume Slider | Speaker ]
        Rectangle {
            anchors.right: parent.right
            anchors.rightMargin: Theme.spaced(20)
            anchors.verticalCenter: parent.verticalCenter
            height: Theme.sized(32)
            width: rowTopRight.width + Theme.spaced(20)
            radius: height / 2
            color: Qt.rgba(0, 0, 0, 0.25)
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.16)

            Row {
                id: rowTopRight
                anchors.centerIn: parent
                spacing: Theme.spaced(10)

                AppleIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: "airplay"
                    size: Theme.sized(15)
                    color: "#FFFFFF"
                }

                // Volume Scrubber
                Item {
                    anchors.verticalCenter: parent.verticalCenter
                    width: Theme.sized(84)
                    height: Theme.sized(16)

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        height: 3
                        radius: 1.5
                        color: Qt.rgba(1, 1, 1, 0.28)

                        Rectangle {
                            width: parent.width * (PlaybackController.volume / 100.0)
                            height: parent.height
                            radius: 1.5
                            color: "#FFFFFF"
                        }
                    }

                    // Thumb
                    Rectangle {
                        x: Math.max(0, Math.min(parent.width - width, (parent.width * (PlaybackController.volume / 100.0)) - width / 2))
                        anchors.verticalCenter: parent.verticalCenter
                        width: 10
                        height: 10
                        radius: 5
                        color: "#FFFFFF"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onPositionChanged: mouse => {
                            if (pressed) {
                                const v = Math.max(0, Math.min(100, Math.round((mouse.x / width) * 100)));
                                PlaybackController.setVolume(v);
                            }
                        }
                        onClicked: mouse => {
                            const v = Math.max(0, Math.min(100, Math.round((mouse.x / width) * 100)));
                            PlaybackController.setVolume(v);
                        }
                    }
                }

                AppleIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: "volume_up"
                    size: Theme.sized(15)
                    color: "#FFFFFF"
                }
            }
        }
    }

    // Stage Container (Two columns: Left = Cover + Scrubber + Controls, Right = Lyrics / Up Next)
    Item {
        id: stageContainer

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(parent.width - Theme.spaced(80), Theme.sized(1200))
        height: Math.min(parent.height - Theme.spaced(80), Theme.sized(640))

        // LEFT COLUMN: Artwork, Track Info, Scrubber & Transport Controls
        Item {
            id: leftStage

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(Theme.sized(380), Math.min(stageContainer.height * 0.58, stageContainer.width * 0.40))
            height: coverBox.height + Theme.spaced(18) + trackInfoRow.height + Theme.spaced(12) + scrubber.height + Theme.spaced(6) + timeRow.height + Theme.spaced(16) + controlsRow.height

            // Album Artwork with Apple drop shadow
            Item {
                id: coverBox

                width: parent.width
                height: width

                RectangularShadow {
                    anchors.fill: parent
                    radius: cover.rounding
                    blur: 32
                    spread: 1
                    offset: Qt.vector2d(0, 10)
                    color: Qt.rgba(0, 0, 0, 0.40)
                }

                Artwork {
                    id: cover

                    anchors.fill: parent
                    artId: switcher.track.artId
                    rounding: Theme.sized(14)
                }
            }

            // Track Title & Subtitle + Favorite Star & More Actions
            Item {
                id: trackInfoRow

                anchors.top: coverBox.bottom
                anchors.topMargin: Theme.spaced(18)
                width: parent.width
                height: Theme.sized(44)

                Column {
                    anchors.left: parent.left
                    anchors.right: trackActions.left
                    anchors.rightMargin: Theme.spaced(10)
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spaced(2)

                    StyledText {
                        width: parent.width
                        text: switcher.track.valid ? switcher.track.title : qsTr("Not Playing")
                        font.bold: true
                        font.pixelSize: Theme.sized(17)
                        color: "#FFFFFF"
                        elide: Text.ElideRight
                    }

                    StyledText {
                        width: parent.width
                        text: switcher.track.valid ? (switcher.track.artist + (switcher.track.album ? " — " + switcher.track.album : "")) : ""
                        font.pixelSize: Theme.sized(13)
                        color: Qt.rgba(1, 1, 1, 0.70)
                        elide: Text.ElideRight
                    }
                }

                Row {
                    id: trackActions
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spaced(4)

                    IconButton {
                        anchors.verticalCenter: parent.verticalCenter
                        icon: PlaybackController.track.liked ? "star_fill" : "star"
                        iconSize: Theme.sized(18)
                        diameter: Theme.sized(32)
                        colIcon: PlaybackController.track.liked ? "#FA2D48" : Qt.rgba(1, 1, 1, 0.80)
                        colBackground: Qt.rgba(1, 1, 1, 0.12)
                        Accessible.name: qsTr("Favorite")
                        onClicked: PlaybackController.rate(PlaybackController.track.liked ? 0 : 1)
                    }

                    IconButton {
                        id: moreBtn
                        anchors.verticalCenter: parent.verticalCenter
                        icon: "more_horiz"
                        iconSize: Theme.sized(18)
                        diameter: Theme.sized(32)
                        colIcon: Qt.rgba(1, 1, 1, 0.85)
                        colBackground: Qt.rgba(1, 1, 1, 0.12)
                        Accessible.name: qsTr("More actions")
                        onClicked: {
                            const spot = leftStage.mapFromItem(moreBtn, moreBtn.width / 2, moreBtn.height);
                            trackMenu.show({ "entry": PlaybackController.currentEntry(),
                                             "source": moreBtn, "x": spot.x,
                                             "y": spot.y, "selectable": false });
                        }
                    }
                }
            }

            // Sleek Progress Scrubber
            Item {
                id: scrubber

                anchors.top: trackInfoRow.bottom
                anchors.topMargin: Theme.spaced(12)
                width: parent.width
                height: Theme.sized(14)

                readonly property real progress: PlaybackController.duration > 0
                    ? Math.max(0, Math.min(1, PlaybackController.position / PlaybackController.duration)) : 0

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: 4
                    radius: 2
                    color: Qt.rgba(1, 1, 1, 0.25)

                    Rectangle {
                        width: parent.width * scrubber.progress
                        height: parent.height
                        radius: 2
                        color: "#FFFFFF"
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: mouse => {
                        if (PlaybackController.duration > 0) {
                            const ratio = Math.max(0, Math.min(1, mouse.x / width));
                            PlaybackController.seek(ratio * PlaybackController.duration);
                        }
                    }

                    onPositionChanged: mouse => {
                        if (pressed && PlaybackController.duration > 0) {
                            const ratio = Math.max(0, Math.min(1, mouse.x / width));
                            PlaybackController.seek(ratio * PlaybackController.duration);
                        }
                    }
                }
            }

            // Time Row with Dolby Atmos Badge
            Item {
                id: timeRow

                anchors.top: scrubber.bottom
                anchors.topMargin: Theme.spaced(6)
                width: parent.width
                height: Theme.sized(16)

                StyledText {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: PlaybackController.formatTime(PlaybackController.position)
                    font.pixelSize: Theme.sized(11)
                    color: Qt.rgba(1, 1, 1, 0.65)
                }

                // Dolby Atmos audio badge
                Row {
                    anchors.centerIn: parent
                    spacing: Theme.spaced(4)

                    AppleIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: "dolby_atmos"
                        size: Theme.sized(13)
                        color: Qt.rgba(1, 1, 1, 0.60)
                    }

                    StyledText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Dolby Atmos"
                        font.pixelSize: Theme.sized(11)
                        font.bold: true
                        color: Qt.rgba(1, 1, 1, 0.60)
                    }
                }

                StyledText {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: "-" + PlaybackController.formatTime(Math.max(0, PlaybackController.duration - PlaybackController.position))
                    font.pixelSize: Theme.sized(11)
                    color: Qt.rgba(1, 1, 1, 0.65)
                }
            }

            // Transport Controls Row: [⇄] [◀◀] [❚❚] [▶▶] [↻]
            Row {
                id: controlsRow

                anchors.top: timeRow.bottom
                anchors.topMargin: Theme.spaced(16)
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.spaced(18)

                IconButton {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "shuffle"
                    iconSize: Theme.sized(20)
                    diameter: Theme.sized(38)
                    colIcon: PlaybackController.shuffle ? "#FA2D48" : Qt.rgba(1, 1, 1, 0.70)
                    Accessible.name: qsTr("Shuffle")
                    onClicked: PlaybackController.shuffle = !PlaybackController.shuffle
                }

                IconButton {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "backward"
                    iconSize: Theme.sized(24)
                    diameter: Theme.sized(44)
                    colIcon: "#FFFFFF"
                    Accessible.name: qsTr("Previous track")
                    onClicked: PlaybackController.previous()
                }

                IconButton {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: PlaybackController.playing ? "pause" : "play"
                    iconSize: Theme.sized(28)
                    diameter: Theme.sized(52)
                    colIcon: "#FFFFFF"
                    Accessible.name: PlaybackController.playing ? qsTr("Pause") : qsTr("Play")
                    onClicked: PlaybackController.toggle()
                }

                IconButton {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "forward"
                    iconSize: Theme.sized(24)
                    diameter: Theme.sized(44)
                    colIcon: "#FFFFFF"
                    Accessible.name: qsTr("Next track")
                    onClicked: PlaybackController.next()
                }

                IconButton {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: PlaybackController.repeat === 2 ? "repeat_one" : "repeat"
                    iconSize: Theme.sized(20)
                    diameter: Theme.sized(38)
                    colIcon: PlaybackController.repeat > 0 ? "#FA2D48" : Qt.rgba(1, 1, 1, 0.70)
                    Accessible.name: qsTr("Repeat")
                    onClicked: PlaybackController.cycleRepeat()
                }
            }
        }

        // RIGHT COLUMN: Giant Time-Synced Lyrics (or Up Next queue)
        Item {
            id: rightStage

            anchors.left: leftStage.right
            anchors.leftMargin: Theme.spaced(72)
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            LyricsPane {
                anchors.fill: parent
                enabled: root.lyricsShown
                opacity: root.lyricsShown ? 1 : 0
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.duration.fast
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Theme.curve.expressiveEffects
                    }
                }
            }

            QueuePane {
                anchors.fill: parent
                enabled: root.queueShown
                onSourceRequested: source => {
                    root.collapseRequested();
                    Browser.open(source);
                }
                opacity: root.queueShown ? 1 : 0
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.duration.fast
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Theme.curve.expressiveEffects
                    }
                }
            }
        }
    }

    // Bottom-Right Floating Pill: [ 💬 Lyrics | ≣ Queue ]
    Rectangle {
        anchors.right: parent.right
        anchors.rightMargin: Theme.spaced(32)
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.spaced(24)
        height: Theme.sized(36)
        width: rowBottomRight.width + Theme.spaced(8)
        radius: height / 2
        color: Qt.rgba(0, 0, 0, 0.35)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.16)
        z: 20

        Row {
            id: rowBottomRight
            anchors.centerIn: parent
            spacing: Theme.spaced(3)

            // Lyrics Toggle Pill
            Rectangle {
                width: Theme.sized(32)
                height: Theme.sized(28)
                radius: Theme.sized(14)
                color: root.pane === 0 ? Qt.rgba(1, 1, 1, 0.28) : "transparent"

                AppleIcon {
                    anchors.centerIn: parent
                    name: "lyrics"
                    size: Theme.sized(16)
                    color: root.pane === 0 ? "#FFFFFF" : Qt.rgba(1, 1, 1, 0.65)
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.pane = 0
                }
            }

            // Queue Toggle Pill
            Rectangle {
                width: Theme.sized(32)
                height: Theme.sized(28)
                radius: Theme.sized(14)
                color: root.pane === 1 ? Qt.rgba(1, 1, 1, 0.28) : "transparent"

                AppleIcon {
                    anchors.centerIn: parent
                    name: "queue"
                    size: Theme.sized(16)
                    color: root.pane === 1 ? "#FFFFFF" : Qt.rgba(1, 1, 1, 0.65)
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.pane = 1
                }
            }
        }
    }

    ItemMenu {
        id: trackMenu

        parent: Overlay.overlay
        builder: entry => Actions.buildPlayer(entry)
    }

    Component.onCompleted: root.pane = 0
}
