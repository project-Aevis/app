import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import HtMusic

Item {
    id: root

    readonly property real contentWidth: Math.min(root.width, Theme.size.contentMaxWidth - Theme.spacing.bleed * 2)
    readonly property bool showShuffleRepeat: root.contentWidth >= 600
    readonly property bool showRating: root.contentWidth >= 800
    readonly property bool wideVolume: root.contentWidth >= 960
    readonly property bool showTime: root.contentWidth >= 700
    readonly property bool loaded: PlaybackController.track.valid
    readonly property bool episode: PlaybackController.episode
    readonly property real musicPresence: Math.max(0, Math.min(1, 1 - root.podcastReveal))
    readonly property real podcastPresence: Math.max(0, Math.min(1, root.podcastReveal))

    property real podcastReveal: root.episode ? 1 : 0
    property real radius: height / 2

    signal expandRequested
    signal pageRequested(string browseId, string kind)

    function openTrackMenu(x) {
        trackMenu.show({ "entry": PlaybackController.currentEntry(), "source": root, "x": x, "y": 0,
                         "selectable": false, "above": true });
    }

    implicitHeight: Theme.sized(58)
    implicitWidth: Math.min(Theme.sized(760), parent ? parent.width - Theme.spaced(32) : Theme.sized(760))

    Behavior on podcastReveal {
        NumberAnimation {
            duration: Theme.duration.spatial
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.curve.emphasized
        }
    }

    TrackSwitch {
        id: switcher

        vertical: true
        travel: 14
        dip: 0.16
    }

    // Ambient Frosted Drop Shadow
    RectangularShadow {
        anchors.fill: parent
        radius: root.radius
        blur: 24
        spread: 0
        offset: Qt.vector2d(0, 4)
        color: Qt.rgba(0, 0, 0, Theme.darkMode ? 0.42 : 0.12)
        z: 0
    }

    // Frosted Glass Capsule Background
    Rectangle {
        id: capsuleBg

        anchors.fill: parent
        radius: root.radius
        z: 1
        color: Theme.darkMode
            ? Qt.rgba(0.14, 0.14, 0.18, 0.70)
            : Qt.rgba(1.0, 1.0, 1.0, 0.70)
        border.width: 1
        border.color: Theme.darkMode
            ? Qt.rgba(1.0, 1.0, 1.0, 0.14)
            : Qt.rgba(0.0, 0.0, 0.0, 0.08)

        // Specular inner reflection rim
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: Math.max(0, parent.radius - 1)
            color: "transparent"
            border.width: 1
            border.color: Theme.darkMode
                ? Qt.rgba(1.0, 1.0, 1.0, 0.08)
                : Qt.rgba(1.0, 1.0, 1.0, 0.70)
        }
    }

    // Main Content
    Item {
        id: body

        anchors.fill: parent
        anchors.leftMargin: Theme.spaced(14)
        anchors.rightMargin: Theme.spaced(14)
        z: 2

        // LEFT: Transport Controls
        Row {
            id: transport

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.spaced(2)

            TapHandler {
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                gesturePolicy: TapHandler.ReleaseWithinBounds
            }

            IconButton {
                anchors.verticalCenter: parent.verticalCenter
                icon: "shuffle"
                iconSize: Theme.sized(18)
                toggled: PlaybackController.shuffle
                colIcon: toggled ? "#FA2D48" : Theme.colOnSurfaceVariant
                opacity: root.musicPresence
                visible: root.showShuffleRepeat && !root.episode
                interactive: !root.episode
                Accessible.name: qsTr("Shuffle")
                onClicked: PlaybackController.shuffle = !PlaybackController.shuffle
            }

            SkipButton {
                anchors.verticalCenter: parent.verticalCenter
                morph: root.podcastReveal
                Accessible.name: root.episode ? qsTr("Back 10 seconds") : qsTr("Previous track")
                interactive: root.episode ? root.loaded : PlaybackController.canGoPrevious
                opacity: interactive ? 1 : 0.35
                onClicked: {
                    if (root.episode)
                        PlaybackController.skip(-10000);
                    else
                        PlaybackController.previous();
                }
            }

            PlayPauseButton {
                anchors.verticalCenter: parent.verticalCenter
                playing: PlaybackController.playing
                iconSize: Theme.sized(20)
                diameter: Theme.sized(36)
                interactive: root.loaded
                opacity: interactive ? 1 : 0.35
                colBackground: Theme.darkMode ? "#FFFFFF" : "#1C1C1E"
                colState: Theme.darkMode ? "#E5E5EA" : "#3A3A3C"
                colGlyph: Theme.darkMode ? "#1C1C1E" : "#FFFFFF"
                onClicked: PlaybackController.toggle()
            }

            SkipButton {
                anchors.verticalCenter: parent.verticalCenter
                forward: true
                morph: root.podcastReveal
                Accessible.name: root.episode ? qsTr("Forward 30 seconds") : qsTr("Next track")
                interactive: root.episode ? root.loaded : PlaybackController.canGoNext
                opacity: interactive ? 1 : 0.35
                onClicked: {
                    if (root.episode)
                        PlaybackController.skip(30000);
                    else
                        PlaybackController.next();
                }
            }

            IconButton {
                anchors.verticalCenter: parent.verticalCenter
                icon: PlaybackController.repeat === 2 ? "repeat_one" : "repeat"
                iconSize: Theme.sized(18)
                toggled: PlaybackController.repeat > 0
                colIcon: toggled ? "#FA2D48" : Theme.colOnSurfaceVariant
                opacity: root.musicPresence
                visible: root.showShuffleRepeat && !root.episode
                interactive: !root.episode
                Accessible.name: qsTr("Repeat")
                onClicked: PlaybackController.cycleRepeat()
            }
        }

        // CENTER: Track Info + Scrubber
        Item {
            id: centerStage

            anchors.left: transport.right
            anchors.leftMargin: Theme.spaced(12)
            anchors.right: trailing.left
            anchors.rightMargin: Theme.spaced(12)
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height

            Row {
                id: trackInfoRow

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: Theme.spaced(6)
                height: Theme.sized(26)
                spacing: Theme.spaced(10)

                // Artwork Thumbnail
                Item {
                    id: coverThumb

                    anchors.verticalCenter: parent.verticalCenter
                    width: Theme.sized(28)
                    height: Theme.sized(28)
                    opacity: switcher.fade
                    scale: switcher.depth

                    Artwork {
                        anchors.fill: parent
                        artId: switcher.track.artId
                        rounding: Theme.sized(5)
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.expandRequested()
                    }
                }

                // Title + Artist
                Item {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - coverThumb.width - parent.spacing - (ratingArea.visible ? ratingArea.width : 0)
                    height: parent.height
                    clip: true

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: switcher.track.valid ? Qt.PointingHandCursor : Qt.ArrowCursor
                        enabled: switcher.track.valid
                        z: -1
                        onClicked: root.expandRequested()
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        spacing: 0
                        opacity: switcher.fade
                        transform: Translate { y: switcher.offsetY }

                        Item {
                            width: parent.width
                            height: titleRow.height

                            Row {
                                id: titleRow
                                width: parent.width
                                spacing: Theme.spaced(4)

                                Marquee {
                                    width: Math.min(implicitWidth, parent.width - Theme.spaced(16))
                                    text: switcher.track.valid ? switcher.track.title : qsTr("Not Playing")
                                    title: switcher.track.valid
                                    color: switcher.track.valid ? Theme.colOnSurface : Theme.colInactive
                                    pixelSize: 11
                                    active: PlaybackController.playing
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: switcher.track.valid ? Qt.PointingHandCursor : Qt.ArrowCursor
                                enabled: switcher.track.valid
                                onClicked: root.expandRequested()
                            }
                        }

                        CreditLine {
                            width: parent.width
                            visible: switcher.track.valid
                            credits: switcher.track.credits
                            album: switcher.track.album
                            albumId: switcher.track.albumId
                            fallback: switcher.track.artist
                            interactive: Connectivity.online
                            onPageRequested: (browseId, kind) => root.pageRequested(browseId, kind)
                        }
                    }
                }

                // Favorite / Rating Heart
                Item {
                    id: ratingArea
                    anchors.verticalCenter: parent.verticalCenter
                    width: Theme.sized(24)
                    height: Theme.sized(24)
                    visible: root.showRating && Account.signedIn && PlaybackController.track.valid

                    LikeButton {
                        anchors.centerIn: parent
                        videoId: PlaybackController.track.videoId
                        liked: PlaybackController.track.liked
                        disliked: PlaybackController.track.disliked
                    }
                }
            }

            // Scrubber Bar
            Item {
                id: scrubberArea

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: trackInfoRow.bottom
                anchors.topMargin: Theme.spaced(1)
                height: Theme.sized(16)

                StyledText {
                    id: elapsedLabel
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.showTime && root.loaded && !PlaybackController.live
                    text: PlaybackController.formatTime(PlaybackController.position)
                    font.pixelSize: 9
                    color: Theme.colInactive
                }

                SeekBar {
                    id: seek

                    anchors.left: elapsedLabel.visible ? elapsedLabel.right : parent.left
                    anchors.leftMargin: elapsedLabel.visible ? Theme.spaced(6) : 0
                    anchors.right: remainingLabel.visible ? remainingLabel.left : parent.right
                    anchors.rightMargin: remainingLabel.visible ? Theme.spaced(6) : 0
                    anchors.verticalCenter: parent.verticalCenter
                    trackHeight: 2.5
                    activeTrackHeight: 4
                    position: PlaybackController.position
                    duration: PlaybackController.duration
                    live: PlaybackController.live
                    enabled: root.loaded
                    opacity: root.loaded ? 1 : 0.35
                    onSeeked: milliseconds => PlaybackController.seek(milliseconds)
                }

                StyledText {
                    id: remainingLabel
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.showTime && root.loaded && !PlaybackController.live
                    text: "-" + PlaybackController.formatTime(Math.max(0, PlaybackController.duration - PlaybackController.position))
                    font.pixelSize: 9
                    color: Theme.colInactive
                }
            }
        }

        // RIGHT: Utility Actions & Volume
        Row {
            id: trailing

            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.spaced(2)

            TapHandler {
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                gesturePolicy: TapHandler.ReleaseWithinBounds
            }

            // More Options (...)
            IconButton {
                anchors.verticalCenter: parent.verticalCenter
                icon: "more_horiz"
                iconSize: Theme.sized(18)
                Accessible.name: qsTr("More options")
                onClicked: root.openTrackMenu(x)
            }

            // Lyrics Toggle
            IconButton {
                anchors.verticalCenter: parent.verticalCenter
                icon: "lyrics"
                iconSize: Theme.sized(18)
                Accessible.name: qsTr("Lyrics")
                onClicked: root.expandRequested()
            }

            // Queue / Playing Next Toggle
            IconButton {
                anchors.verticalCenter: parent.verticalCenter
                icon: "queue"
                iconSize: Theme.sized(18)
                Accessible.name: qsTr("Playing Next")
                onClicked: root.expandRequested()
            }

            // AirPlay
            IconButton {
                anchors.verticalCenter: parent.verticalCenter
                icon: "airplay"
                iconSize: Theme.sized(18)
                Accessible.name: qsTr("AirPlay")
                onClicked: root.expandRequested()
            }

            // Sound / Equalizer
            IconButton {
                id: tune
                anchors.verticalCenter: parent.verticalCenter
                icon: "graphic_eq"
                iconSize: Theme.sized(18)
                toggled: PlaybackSettings.equalizerEnabled
                    || PlaybackSettings.transitionMode !== PlaybackSettings.TransitionsOff
                colIcon: toggled ? "#FA2D48" : Theme.colOnSurfaceVariant
                Accessible.name: qsTr("Sound")
                onClicked: tuning.toggle()
            }

            // Volume Control
            VolumeControl {
                anchors.verticalCenter: parent.verticalCenter
                compact: !root.wideVolume
            }
        }
    }

    ItemMenu {
        id: trackMenu

        parent: Overlay.overlay
        builder: entry => Actions.buildPlayer(entry)
    }

    TuningPopup {
        id: tuning

        parent: root
        x: trailing.x + Theme.spaced(40)
        y: -height - Theme.spaced(10)
        anchorX: 0.8
        anchorY: 1
    }
}
