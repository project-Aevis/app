import QtQuick
import QtQuick.Effects
import HtMusic

Item {
    id: root

    property string artId: ""
    property bool flipped: false
    property real blend: root.flipped ? 1 : 0

    readonly property string source: root.artId
        ? "image://art/" + encodeURIComponent(root.artId) : ""
    readonly property int canvasWidth: 512
    readonly property int canvasHeight: Math.max(1, Math.round(
        root.canvasWidth * root.height / Math.max(1, root.width)))

    Item {
        id: canvas

        anchors.centerIn: parent
        width: root.canvasWidth
        height: root.canvasHeight
        scale: Math.max(root.width / root.canvasWidth, root.height / root.canvasHeight) * 1.35
        layer.enabled: true
        layer.smooth: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: 1.0
            blurMax: 56
            saturation: 0.65
            contrast: 0.16
            brightness: 0.04
        }

        Image {
            id: leading

            anchors.fill: parent
            sourceSize.width: 512
            sourceSize.height: 512
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            opacity: 1 - root.blend

            onStatusChanged: if (status === Image.Ready && root.flipped) root.flipped = false
        }

        Image {
            id: trailing

            anchors.fill: parent
            sourceSize.width: 512
            sourceSize.height: 512
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            opacity: root.blend

            onStatusChanged: if (status === Image.Ready && !root.flipped) root.flipped = true
        }
    }

    onSourceChanged: {
        const incoming = root.flipped ? leading : trailing;
        incoming.source = root.source;
        if (!root.source)
            root.flipped = !root.flipped;
    }

    Behavior on blend {
        NumberAnimation {
            duration: Theme.duration.sheetEnter
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.curve.expressiveEffects
        }
    }
}
