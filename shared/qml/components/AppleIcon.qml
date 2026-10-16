import QtQuick
import HtMusic

Item {
    id: root

    property string name: ""
    property real size: Theme.sized(18)
    property color color: Theme.colOnSurfaceVariant
    property bool active: false
    property color activeColor: root.color !== Theme.colOnSurfaceVariant ? root.color : "#FA2D48"
    property real fill: 0

    readonly property color drawColor: root.active ? root.activeColor : root.color

    implicitWidth: size
    implicitHeight: size

    function isVectorSupported(n) {
        switch (n) {
        case "search":
        case "listen_now":
        case "home":
        case "browse":
        case "explore":
        case "new":
        case "radio":
        case "pin":
        case "pushpin":
        case "recently_added":
        case "schedule":
        case "artists":
        case "mic":
        case "albums":
        case "album":
        case "songs":
        case "music_note":
        case "music_videos":
        case "video":
        case "made_for_you":
        case "itunes_store":
        case "collaborative":
        case "people":
        case "explicit":
        case "lossless":
        case "downloaded":
        case "download":
        case "download_for_offline":
        case "playlists":
        case "queue_music":
        case "play":
        case "play_arrow":
        case "pause":
        case "previous":
        case "skip_previous":
        case "backward":
        case "backward_fill":
        case "next":
        case "skip_next":
        case "forward":
        case "forward_fill":
        case "shuffle":
        case "repeat":
        case "repeat_one":
        case "lyrics":
        case "quote_bubble":
        case "chat_bubble":
        case "queue":
        case "queue_music_bullets":
        case "more":
        case "more_horiz":
        case "more_vert":
        case "favorite":
        case "favorite_border":
        case "heart":
        case "star":
        case "star_fill":
        case "star_border":
        case "pip":
        case "picture_in_picture":
        case "miniplayer":
        case "airplay":
        case "airplayaudio":
        case "dolby_atmos":
        case "chevron_left":
        case "back":
        case "arrow_back":
        case "chevron_right":
        case "forward":
        case "expand_more":
        case "chevron_down":
        case "add":
        case "plus":
        case "remove":
        case "minus":
        case "close":
        case "clear":
        case "check":
        case "check_circle":
        case "refresh":
        case "restart_alt":
        case "settings":
        case "extension":
        case "person":
        case "account_circle":
        case "graphic_eq":
        case "tune":
        case "sound":
        case "volume_up":
        case "volume_down":
        case "volume_mute":
        case "volume_off":
        case "volume":
        case "cloud_off":
        case "delete":
        case "edit":
        case "share":
        case "podcasts":
        case "info":
        case "folder_open":
        case "arrow_drop_up":
        case "arrow_drop_down":
            return true;
        default:
            return false;
        }
    }

    readonly property bool isVector: isVectorSupported(root.name)

    Canvas {
        id: canvas

        anchors.fill: parent
        renderTarget: Canvas.Image
        renderStrategy: Canvas.Cooperative
        visible: root.isVector

        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            ctx.clearRect(0, 0, width, height);

            if (!root.isVector)
                return;

            const s = width;
            const c = root.drawColor;
            ctx.fillStyle = c;
            ctx.strokeStyle = c;
            ctx.lineCap = "round";
            ctx.lineJoin = "round";

            switch (root.name) {
            case "search":
                // Apple SF Search: sleek magnifying glass outline
                ctx.lineWidth = s * 0.082;
                ctx.beginPath();
                ctx.arc(s * 0.42, s * 0.42, s * 0.25, 0, 2 * Math.PI);
                ctx.stroke();
                ctx.beginPath();
                ctx.moveTo(s * 0.60, s * 0.60);
                ctx.lineTo(s * 0.84, s * 0.84);
                ctx.stroke();
                break;

            case "home":
                // Apple SF House: pitched roof with chimney and house body
                ctx.lineWidth = s * 0.082;
                // Roof
                ctx.beginPath();
                ctx.moveTo(s * 0.16, s * 0.46);
                ctx.lineTo(s * 0.50, s * 0.18);
                ctx.lineTo(s * 0.84, s * 0.46);
                ctx.stroke();
                // Chimney on right
                ctx.beginPath();
                ctx.moveTo(s * 0.69, s * 0.32);
                ctx.lineTo(s * 0.69, s * 0.22);
                ctx.lineTo(s * 0.77, s * 0.22);
                ctx.lineTo(s * 0.77, s * 0.38);
                ctx.stroke();
                // House walls with rounded bottom corners
                ctx.beginPath();
                ctx.moveTo(s * 0.25, s * 0.44);
                ctx.lineTo(s * 0.25, s * 0.79);
                ctx.arcTo(s * 0.25, s * 0.84, s * 0.30, s * 0.84, s * 0.05);
                ctx.lineTo(s * 0.70, s * 0.84);
                ctx.arcTo(s * 0.75, s * 0.84, s * 0.75, s * 0.79, s * 0.05);
                ctx.lineTo(s * 0.75, s * 0.44);
                ctx.stroke();
                break;

            case "listen_now":
                // Apple Listen Now circle play
                ctx.lineWidth = s * 0.082;
                ctx.beginPath();
                ctx.arc(s * 0.5, s * 0.5, s * 0.40, 0, 2 * Math.PI);
                ctx.stroke();
                ctx.beginPath();
                ctx.moveTo(s * 0.42, s * 0.33);
                ctx.lineTo(s * 0.67, s * 0.5);
                ctx.lineTo(s * 0.42, s * 0.67);
                ctx.closePath();
                ctx.fill();
                break;

            case "browse":
            case "explore":
            case "new":
                // Apple New: 4 rounded outline squares (2x2 grid)
                ctx.lineWidth = s * 0.082;
                const sz = s * 0.30;
                const r = s * 0.07;
                const drawTile = (x, y) => {
                    ctx.beginPath();
                    ctx.roundedRect(x, y, sz, sz, r, r);
                    ctx.stroke();
                };
                drawTile(s * 0.15, s * 0.15);
                drawTile(s * 0.55, s * 0.15);
                drawTile(s * 0.15, s * 0.55);
                drawTile(s * 0.55, s * 0.55);
                break;

            case "radio":
                // Apple Radio: central broadcast dot + radiating wave arcs
                ctx.lineWidth = s * 0.082;
                ctx.beginPath();
                ctx.arc(s * 0.50, s * 0.48, s * 0.08, 0, 2 * Math.PI);
                ctx.fill();
                // Inner waves
                ctx.beginPath();
                ctx.arc(s * 0.50, s * 0.48, s * 0.20, Math.PI * 0.65, Math.PI * 1.35);
                ctx.stroke();
                ctx.beginPath();
                ctx.arc(s * 0.50, s * 0.48, s * 0.20, -Math.PI * 0.35, Math.PI * 0.35);
                ctx.stroke();
                // Outer waves
                ctx.beginPath();
                ctx.arc(s * 0.50, s * 0.48, s * 0.36, Math.PI * 0.65, Math.PI * 1.35);
                ctx.stroke();
                ctx.beginPath();
                ctx.arc(s * 0.50, s * 0.48, s * 0.36, -Math.PI * 0.35, Math.PI * 0.35);
                ctx.stroke();
                break;

            case "pin":
            case "pushpin":
                // Apple Pin / Pushpin tack outline
                ctx.lineWidth = s * 0.082;
                // Pin head top bar
                ctx.beginPath();
                ctx.moveTo(s * 0.34, s * 0.18);
                ctx.lineTo(s * 0.66, s * 0.18);
                // Body tapering and flange
                ctx.moveTo(s * 0.40, s * 0.18);
                ctx.lineTo(s * 0.44, s * 0.46);
                ctx.lineTo(s * 0.30, s * 0.54);
                ctx.lineTo(s * 0.70, s * 0.54);
                ctx.lineTo(s * 0.56, s * 0.46);
                ctx.lineTo(s * 0.60, s * 0.18);
                ctx.stroke();
                // Needle point
                ctx.beginPath();
                ctx.moveTo(s * 0.50, s * 0.54);
                ctx.lineTo(s * 0.50, s * 0.86);
                ctx.stroke();
                break;

            case "recently_added":
            case "schedule":
                // Apple Clock with hands
                ctx.lineWidth = s * 0.082;
                ctx.beginPath();
                ctx.arc(s * 0.50, s * 0.50, s * 0.39, 0, 2 * Math.PI);
                ctx.stroke();
                ctx.beginPath();
                ctx.moveTo(s * 0.50, s * 0.25);
                ctx.lineTo(s * 0.50, s * 0.50);
                ctx.lineTo(s * 0.68, s * 0.50);
                ctx.stroke();
                break;

            case "artists":
            case "mic":
                // Apple Microphone
                ctx.lineWidth = s * 0.082;
                ctx.beginPath();
                ctx.roundedRect(s * 0.37, s * 0.12, s * 0.26, s * 0.44, s * 0.13, s * 0.13);
                ctx.stroke();
                ctx.beginPath();
                ctx.arc(s * 0.50, s * 0.42, s * 0.24, 0, Math.PI);
                ctx.stroke();
                ctx.beginPath();
                ctx.moveTo(s * 0.50, s * 0.66);
                ctx.lineTo(s * 0.50, s * 0.85);
                ctx.moveTo(s * 0.34, s * 0.85);
                ctx.lineTo(s * 0.66, s * 0.85);
                ctx.stroke();
                break;

            case "albums":
            case "album":
                // Apple Albums: stacked sleeves in bin
                ctx.lineWidth = s * 0.082;
                // Back sleeve rim
                ctx.beginPath();
                ctx.moveTo(s * 0.22, s * 0.28);
                ctx.lineTo(s * 0.22, s * 0.20);
                ctx.arcTo(s * 0.22, s * 0.16, s * 0.26, s * 0.16, s * 0.04);
                ctx.lineTo(s * 0.74, s * 0.16);
                ctx.arcTo(s * 0.78, s * 0.16, s * 0.78, s * 0.20, s * 0.04);
                ctx.lineTo(s * 0.78, s * 0.28);
                ctx.stroke();
                // Middle layer rim
                ctx.beginPath();
                ctx.moveTo(s * 0.19, s * 0.38);
                ctx.lineTo(s * 0.19, s * 0.26);
                ctx.lineTo(s * 0.81, s * 0.26);
                ctx.lineTo(s * 0.81, s * 0.38);
                ctx.stroke();
                // Front main sleeve
                ctx.beginPath();
                ctx.roundedRect(s * 0.16, s * 0.32, s * 0.68, s * 0.54, s * 0.08, s * 0.08);
                ctx.stroke();
                break;

            case "songs":
            case "music_note":
                // Apple Beamed Eighth Notes
                ctx.beginPath();
                ctx.ellipse(s * 0.28, s * 0.72, s * 0.13, s * 0.09, -Math.PI / 6, 0, 2 * Math.PI);
                ctx.fill();
                ctx.beginPath();
                ctx.ellipse(s * 0.68, s * 0.62, s * 0.13, s * 0.09, -Math.PI / 6, 0, 2 * Math.PI);
                ctx.fill();
                ctx.lineWidth = s * 0.082;
                ctx.beginPath();
                ctx.moveTo(s * 0.37, s * 0.70);
                ctx.lineTo(s * 0.37, s * 0.23);
                ctx.moveTo(s * 0.77, s * 0.60);
                ctx.lineTo(s * 0.77, s * 0.15);
                ctx.stroke();
                ctx.lineWidth = s * 0.12;
                ctx.beginPath();
                ctx.moveTo(s * 0.37, s * 0.22);
                ctx.lineTo(s * 0.77, s * 0.14);
                ctx.stroke();
                break;

            case "music_videos":
            case "video":
                // Apple Music Videos: display screen with music note inside
                ctx.lineWidth = s * 0.082;
                ctx.beginPath();
                ctx.roundedRect(s * 0.14, s * 0.18, s * 0.72, s * 0.52, s * 0.08, s * 0.08);
                ctx.stroke();
                // Note inside
                ctx.beginPath();
                ctx.ellipse(s * 0.44, s * 0.54, s * 0.08, s * 0.06, -Math.PI / 6, 0, 2 * Math.PI);
                ctx.fill();
                ctx.beginPath();
                ctx.moveTo(s * 0.49, s * 0.53);
                ctx.lineTo(s * 0.49, s * 0.34);
                ctx.lineTo(s * 0.62, s * 0.37);
                ctx.stroke();
                // Screen base stand
                ctx.beginPath();
                ctx.moveTo(s * 0.36, s * 0.82);
                ctx.lineTo(s * 0.44, s * 0.70);
                ctx.moveTo(s * 0.64, s * 0.82);
                ctx.lineTo(s * 0.56, s * 0.70);
                ctx.stroke();
                break;

            case "made_for_you":
                // Apple Made for You: rounded card with user silhouette
                ctx.lineWidth = s * 0.082;
                ctx.beginPath();
                ctx.roundedRect(s * 0.15, s * 0.15, s * 0.70, s * 0.70, s * 0.13, s * 0.13);
                ctx.stroke();
                // Head
                ctx.beginPath();
                ctx.arc(s * 0.50, s * 0.40, s * 0.12, 0, 2 * Math.PI);
                ctx.stroke();
                // Shoulders
                ctx.beginPath();
                ctx.arc(s * 0.50, s * 0.80, s * 0.22, Math.PI * 1.15, Math.PI * 1.85);
                ctx.stroke();
                break;

            case "itunes_store":
                // Apple iTunes Store: shopping bag with 5-point star
                ctx.lineWidth = s * 0.082;
                ctx.beginPath();
                ctx.roundedRect(s * 0.18, s * 0.32, s * 0.64, s * 0.54, s * 0.08, s * 0.08);
                ctx.stroke();
                // Handle
                ctx.beginPath();
                ctx.arc(s * 0.50, s * 0.32, s * 0.15, Math.PI, 0, false);
                ctx.stroke();
                // Star inside
                const itunesCx = s * 0.50;
                const itunesCy = s * 0.58;
                const itunesROuter = s * 0.13;
                const itunesRInner = s * 0.06;
                ctx.beginPath();
                for (let si = 0; si < 10; si++) {
                    const sr = (si % 2 === 0) ? itunesROuter : itunesRInner;
                    const sAngle = -Math.PI / 2 + (si * Math.PI / 5);
                    const spx = itunesCx + sr * Math.cos(sAngle);
                    const spy = itunesCy + sr * Math.sin(sAngle);
                    if (si === 0) ctx.moveTo(spx, spy);
                    else ctx.lineTo(spx, spy);
                }
                ctx.closePath();
                ctx.fill();
                break;

            case "collaborative":
            case "people":
                // Two people silhouettes
                ctx.lineWidth = s * 0.082;
                // Left person
                ctx.beginPath();
                ctx.arc(s * 0.38, s * 0.36, s * 0.11, 0, 2 * Math.PI);
                ctx.stroke();
                ctx.beginPath();
                ctx.arc(s * 0.38, s * 0.78, s * 0.20, Math.PI * 1.15, Math.PI * 1.85);
                ctx.stroke();
                // Right person
                ctx.beginPath();
                ctx.arc(s * 0.66, s * 0.42, s * 0.09, 0, 2 * Math.PI);
                ctx.stroke();
                ctx.beginPath();
                ctx.arc(s * 0.66, s * 0.80, s * 0.16, Math.PI * 1.15, Math.PI * 1.85);
                ctx.stroke();
                break;

            case "explicit":
                // Explicit badge 'E'
                ctx.lineWidth = s * 0.082;
                ctx.beginPath();
                ctx.roundedRect(s * 0.12, s * 0.12, s * 0.76, s * 0.76, s * 0.16, s * 0.16);
                ctx.stroke();
                ctx.font = "bold " + Math.round(s * 0.48) + "px sans-serif";
                ctx.textAlign = "center";
                ctx.textBaseline = "middle";
                ctx.fillText("E", s * 0.50, s * 0.52);
                break;

            case "lossless":
                // Lossless Audio waveform
                ctx.lineWidth = s * 0.082;
                ctx.beginPath();
                ctx.moveTo(s * 0.14, s * 0.50);
                ctx.bezierCurveTo(s * 0.26, s * 0.20, s * 0.38, s * 0.80, s * 0.50, s * 0.50);
                ctx.bezierCurveTo(s * 0.62, s * 0.20, s * 0.74, s * 0.80, s * 0.86, s * 0.50);
                ctx.stroke();
                break;

            case "downloaded":
            case "download":
            case "download_for_offline":
                // Apple Download Tray
                ctx.lineWidth = s * 0.095;
                ctx.beginPath();
                ctx.moveTo(s * 0.5, s * 0.16);
                ctx.lineTo(s * 0.5, s * 0.62);
                ctx.lineTo(s * 0.33, s * 0.45);
                ctx.moveTo(s * 0.5, s * 0.62);
                ctx.lineTo(s * 0.67, s * 0.45);
                ctx.stroke();
                // Curved tray
                ctx.beginPath();
                ctx.moveTo(s * 0.20, s * 0.68);
                ctx.lineTo(s * 0.20, s * 0.82);
                ctx.lineTo(s * 0.80, s * 0.82);
                ctx.lineTo(s * 0.80, s * 0.68);
                ctx.stroke();
                break;

            case "playlists":
            case "queue_music":
                // Apple Playlists (3 tracks + note)
                ctx.lineWidth = s * 0.095;
                ctx.beginPath();
                ctx.moveTo(s * 0.15, s * 0.25);
                ctx.lineTo(s * 0.85, s * 0.25);
                ctx.moveTo(s * 0.15, s * 0.50);
                ctx.lineTo(s * 0.55, s * 0.50);
                ctx.moveTo(s * 0.15, s * 0.75);
                ctx.lineTo(s * 0.50, s * 0.75);
                ctx.stroke();
                ctx.beginPath();
                ctx.arc(s * 0.72, s * 0.72, s * 0.095, 0, 2 * Math.PI);
                ctx.fill();
                ctx.beginPath();
                ctx.moveTo(s * 0.80, s * 0.72);
                ctx.lineTo(s * 0.80, s * 0.44);
                ctx.stroke();
                break;

            case "play":
            case "play_arrow":
                // Apple Play Triangle with slight optical centering & rounded vertices
                ctx.beginPath();
                ctx.lineWidth = s * 0.08;
                ctx.lineJoin = "round";
                ctx.moveTo(s * 0.30, s * 0.20);
                ctx.lineTo(s * 0.78, s * 0.50);
                ctx.lineTo(s * 0.30, s * 0.80);
                ctx.closePath();
                ctx.fill();
                ctx.stroke();
                break;

            case "pause":
                // Apple Pause Dual Rounded Bars
                const bw = s * 0.18;
                const bh = s * 0.62;
                const br = bw / 2;
                ctx.beginPath();
                ctx.roundedRect(s * 0.25, s * 0.19, bw, bh, br, br);
                ctx.fill();
                ctx.beginPath();
                ctx.roundedRect(s * 0.57, s * 0.19, bw, bh, br, br);
                ctx.fill();
                break;

            case "previous":
            case "skip_previous":
            case "backward":
            case "backward_fill":
                // Apple Music double left triangles
                ctx.beginPath();
                ctx.moveTo(s * 0.12, s * 0.50);
                ctx.lineTo(s * 0.48, s * 0.22);
                ctx.lineTo(s * 0.48, s * 0.78);
                ctx.closePath();
                ctx.fill();
                ctx.beginPath();
                ctx.moveTo(s * 0.46, s * 0.50);
                ctx.lineTo(s * 0.82, s * 0.22);
                ctx.lineTo(s * 0.82, s * 0.78);
                ctx.closePath();
                ctx.fill();
                break;

            case "next":
            case "skip_next":
            case "forward":
            case "forward_fill":
                // Apple Music double right triangles
                ctx.beginPath();
                ctx.moveTo(s * 0.18, s * 0.22);
                ctx.lineTo(s * 0.54, s * 0.50);
                ctx.lineTo(s * 0.18, s * 0.78);
                ctx.closePath();
                ctx.fill();
                ctx.beginPath();
                ctx.moveTo(s * 0.52, s * 0.22);
                ctx.lineTo(s * 0.88, s * 0.50);
                ctx.lineTo(s * 0.52, s * 0.78);
                ctx.closePath();
                ctx.fill();
                break;

            case "shuffle":
                // Apple Shuffle Intertwining Arrows
                ctx.lineWidth = s * 0.095;
                ctx.beginPath();
                ctx.moveTo(s * 0.15, s * 0.74);
                ctx.bezierCurveTo(s * 0.45, s * 0.74, s * 0.55, s * 0.26, s * 0.78, s * 0.26);
                ctx.stroke();
                ctx.beginPath();
                ctx.moveTo(s * 0.67, s * 0.16);
                ctx.lineTo(s * 0.84, s * 0.26);
                ctx.lineTo(s * 0.67, s * 0.36);
                ctx.stroke();
                ctx.beginPath();
                ctx.moveTo(s * 0.15, s * 0.26);
                ctx.bezierCurveTo(s * 0.45, s * 0.26, s * 0.55, s * 0.74, s * 0.78, s * 0.74);
                ctx.stroke();
                ctx.beginPath();
                ctx.moveTo(s * 0.67, s * 0.64);
                ctx.lineTo(s * 0.84, s * 0.74);
                ctx.lineTo(s * 0.67, s * 0.84);
                ctx.stroke();
                break;

            case "repeat":
            case "repeat_one":
                // Apple Repeat Looping Arrows
                ctx.lineWidth = s * 0.095;
                ctx.beginPath();
                ctx.arc(s * 0.5, s * 0.5, s * 0.32, -Math.PI * 0.75, Math.PI * 0.75);
                ctx.stroke();
                ctx.beginPath();
                ctx.moveTo(s * 0.35, s * 0.18);
                ctx.lineTo(s * 0.22, s * 0.28);
                ctx.lineTo(s * 0.35, s * 0.38);
                ctx.stroke();
                if (root.name === "repeat_one") {
                    ctx.font = "bold " + Math.round(s * 0.34) + "px SF Pro Text, sans-serif";
                    ctx.textAlign = "center";
                    ctx.textBaseline = "middle";
                    ctx.fillText("1", s * 0.5, s * 0.5);
                }
                break;

            case "lyrics":
            case "chat_bubble":
                // Apple Lyrics (speech bubble with quotes)
                ctx.lineWidth = s * 0.095;
                ctx.beginPath();
                ctx.roundedRect(s * 0.13, s * 0.16, s * 0.74, s * 0.52, s * 0.16, s * 0.16);
                ctx.moveTo(s * 0.32, s * 0.68);
                ctx.lineTo(s * 0.24, s * 0.86);
                ctx.lineTo(s * 0.46, s * 0.68);
                ctx.stroke();
                ctx.font = "bold " + Math.round(s * 0.30) + "px sans-serif";
                ctx.textAlign = "center";
                ctx.textBaseline = "middle";
                ctx.fillText("❝", s * 0.5, s * 0.42);
                break;

            case "queue":
            case "queue_music_bullets":
                // Apple Queue (3 bullets + lines)
                ctx.lineWidth = s * 0.085;
                for (let i = 0; i < 3; i++) {
                    const y = s * (0.26 + i * 0.24);
                    ctx.beginPath();
                    ctx.arc(s * 0.22, y, s * 0.05, 0, 2 * Math.PI);
                    ctx.fill();
                    ctx.beginPath();
                    ctx.moveTo(s * 0.38, y);
                    ctx.lineTo(s * 0.82, y);
                    ctx.stroke();
                }
                break;

            case "more":
            case "more_horiz":
                // Apple 3 dots horizontal
                const radH = s * 0.075;
                for (let i = -1; i <= 1; i++) {
                    ctx.beginPath();
                    ctx.arc(s * (0.5 + i * 0.26), s * 0.5, radH, 0, 2 * Math.PI);
                    ctx.fill();
                }
                break;

            case "more_vert":
                // Apple 3 dots vertical
                const radV = s * 0.075;
                for (let i = -1; i <= 1; i++) {
                    ctx.beginPath();
                    ctx.arc(s * 0.5, s * (0.5 + i * 0.26), radV, 0, 2 * Math.PI);
                    ctx.fill();
                }
                break;

            case "favorite":
            case "favorite_border":
            case "heart":
                // Apple Heart
                ctx.beginPath();
                ctx.moveTo(s * 0.5, s * 0.82);
                ctx.bezierCurveTo(s * 0.18, s * 0.58, s * 0.09, s * 0.38, s * 0.09, s * 0.26);
                ctx.bezierCurveTo(s * 0.09, s * 0.12, s * 0.28, s * 0.12, s * 0.5, s * 0.32);
                ctx.bezierCurveTo(s * 0.72, s * 0.12, s * 0.91, s * 0.12, s * 0.91, s * 0.26);
                ctx.bezierCurveTo(s * 0.91, s * 0.38, s * 0.82, s * 0.58, s * 0.5, s * 0.82);
                ctx.closePath();
                if (root.active || root.name === "favorite") {
                    ctx.fill();
                } else {
                    ctx.lineWidth = s * 0.095;
                    ctx.stroke();
                }
                break;

            case "star":
            case "star_fill":
            case "star_border":
                // Apple 5-Point Star
                const starCx = s * 0.5;
                const starCy = s * 0.52;
                const starROuter = s * 0.44;
                const starRInner = s * 0.20;
                ctx.beginPath();
                for (let si = 0; si < 10; si++) {
                    const sr = (si % 2 === 0) ? starROuter : starRInner;
                    const sAngle = -Math.PI / 2 + (si * Math.PI / 5);
                    const spx = starCx + sr * Math.cos(sAngle);
                    const spy = starCy + sr * Math.sin(sAngle);
                    if (si === 0) ctx.moveTo(spx, spy);
                    else ctx.lineTo(spx, spy);
                }
                ctx.closePath();
                if (root.active || root.name === "star_fill") {
                    ctx.fill();
                } else {
                    ctx.lineWidth = s * 0.09;
                    ctx.stroke();
                }
                break;

            case "pip":
            case "picture_in_picture":
            case "miniplayer":
                // Apple Picture in Picture (two overlapping windows)
                ctx.lineWidth = s * 0.085;
                ctx.beginPath();
                ctx.roundedRect(s * 0.12, s * 0.16, s * 0.76, s * 0.56, s * 0.10, s * 0.10);
                ctx.stroke();
                ctx.beginPath();
                ctx.roundedRect(s * 0.48, s * 0.44, s * 0.40, s * 0.28, s * 0.06, s * 0.06);
                ctx.fill();
                break;

            case "airplay":
            case "airplayaudio":
                // Apple AirPlay Audio
                ctx.beginPath();
                ctx.moveTo(s * 0.5, s * 0.54);
                ctx.lineTo(s * 0.70, s * 0.84);
                ctx.lineTo(s * 0.30, s * 0.84);
                ctx.closePath();
                ctx.fill();
                ctx.lineWidth = s * 0.085;
                ctx.beginPath();
                ctx.arc(s * 0.5, s * 0.78, s * 0.38, -Math.PI * 0.76, -Math.PI * 0.24);
                ctx.stroke();
                ctx.beginPath();
                ctx.arc(s * 0.5, s * 0.78, s * 0.56, -Math.PI * 0.72, -Math.PI * 0.28);
                ctx.stroke();
                break;

            case "dolby_atmos":
                // Dolby Atmos Double-D icon
                ctx.beginPath();
                ctx.arc(s * 0.35, s * 0.5, s * 0.28, -Math.PI / 2, Math.PI / 2, true);
                ctx.closePath();
                ctx.fill();
                ctx.beginPath();
                ctx.arc(s * 0.65, s * 0.5, s * 0.28, -Math.PI / 2, Math.PI / 2, false);
                ctx.closePath();
                ctx.fill();
                break;

            case "chevron_left":
            case "back":
            case "arrow_back":
                // Apple Chevron Left
                ctx.lineWidth = s * 0.11;
                ctx.beginPath();
                ctx.moveTo(s * 0.64, s * 0.22);
                ctx.lineTo(s * 0.36, s * 0.50);
                ctx.lineTo(s * 0.64, s * 0.78);
                ctx.stroke();
                break;

            case "chevron_right":
            case "forward":
                // Apple Chevron Right
                ctx.lineWidth = s * 0.11;
                ctx.beginPath();
                ctx.moveTo(s * 0.36, s * 0.22);
                ctx.lineTo(s * 0.64, s * 0.50);
                ctx.lineTo(s * 0.36, s * 0.78);
                ctx.stroke();
                break;

            case "expand_more":
            case "chevron_down":
                // Apple Chevron Down
                ctx.lineWidth = s * 0.11;
                ctx.beginPath();
                ctx.moveTo(s * 0.22, s * 0.36);
                ctx.lineTo(s * 0.50, s * 0.64);
                ctx.lineTo(s * 0.78, s * 0.36);
                ctx.stroke();
                break;

            case "add":
            case "plus":
                // Apple Plus
                ctx.lineWidth = s * 0.11;
                ctx.beginPath();
                ctx.moveTo(s * 0.5, s * 0.20);
                ctx.lineTo(s * 0.5, s * 0.80);
                ctx.moveTo(s * 0.20, s * 0.5);
                ctx.lineTo(s * 0.80, s * 0.5);
                ctx.stroke();
                break;

            case "remove":
            case "minus":
                // Apple Minus
                ctx.lineWidth = s * 0.11;
                ctx.beginPath();
                ctx.moveTo(s * 0.20, s * 0.5);
                ctx.lineTo(s * 0.80, s * 0.5);
                ctx.stroke();
                break;

            case "close":
            case "clear":
                // Apple Cross ×
                ctx.lineWidth = s * 0.11;
                ctx.beginPath();
                ctx.moveTo(s * 0.26, s * 0.26);
                ctx.lineTo(s * 0.74, s * 0.74);
                ctx.moveTo(s * 0.74, s * 0.26);
                ctx.lineTo(s * 0.26, s * 0.74);
                ctx.stroke();
                break;

            case "check":
            case "check_circle":
                // Apple Checkmark
                ctx.lineWidth = s * 0.11;
                ctx.beginPath();
                ctx.moveTo(s * 0.22, s * 0.52);
                ctx.lineTo(s * 0.42, s * 0.72);
                ctx.lineTo(s * 0.78, s * 0.28);
                ctx.stroke();
                break;

            case "refresh":
            case "restart_alt":
                // Apple Circular Refresh
                ctx.lineWidth = s * 0.095;
                ctx.beginPath();
                ctx.arc(s * 0.5, s * 0.5, s * 0.33, 0.2 * Math.PI, 1.7 * Math.PI);
                ctx.stroke();
                ctx.beginPath();
                ctx.moveTo(s * 0.60, s * 0.20);
                ctx.lineTo(s * 0.45, s * 0.18);
                ctx.lineTo(s * 0.52, s * 0.33);
                ctx.stroke();
                break;

            case "settings":
                // Apple Settings Gear
                ctx.lineWidth = s * 0.085;
                ctx.beginPath();
                ctx.arc(s * 0.5, s * 0.5, s * 0.16, 0, 2 * Math.PI);
                ctx.stroke();
                // 6 teeth
                for (let i = 0; i < 6; i++) {
                    const ang = (i * Math.PI) / 3;
                    const cos = Math.cos(ang);
                    const sin = Math.sin(ang);
                    ctx.beginPath();
                    ctx.moveTo(s * (0.5 + 0.26 * cos), s * (0.5 + 0.26 * sin));
                    ctx.lineTo(s * (0.5 + 0.41 * cos), s * (0.5 + 0.41 * sin));
                    ctx.stroke();
                }
                break;

            case "extension":
                // Apple Puzzle Piece
                ctx.lineWidth = s * 0.09;
                ctx.beginPath();
                ctx.moveTo(s * 0.25, s * 0.25);
                ctx.lineTo(s * 0.45, s * 0.25);
                ctx.arc(s * 0.50, s * 0.25, s * 0.10, Math.PI, 0, false);
                ctx.lineTo(s * 0.75, s * 0.25);
                ctx.lineTo(s * 0.75, s * 0.45);
                ctx.arc(s * 0.75, s * 0.50, s * 0.10, -Math.PI / 2, Math.PI / 2, false);
                ctx.lineTo(s * 0.75, s * 0.75);
                ctx.lineTo(s * 0.25, s * 0.75);
                ctx.closePath();
                ctx.stroke();
                break;

            case "person":
            case "account_circle":
                // Apple User silhouette
                ctx.lineWidth = s * 0.095;
                ctx.beginPath();
                ctx.arc(s * 0.5, s * 0.34, s * 0.17, 0, 2 * Math.PI);
                ctx.stroke();
                ctx.beginPath();
                ctx.arc(s * 0.5, s * 0.88, s * 0.33, Math.PI * 1.15, Math.PI * 1.85);
                ctx.stroke();
                break;

            case "graphic_eq":
            case "tune":
            case "sound":
                // Apple Equalizer Audio Sliders
                ctx.lineWidth = s * 0.085;
                // 3 vertical bars
                const drawSlider = (x, knobY) => {
                    ctx.beginPath();
                    ctx.moveTo(x, s * 0.18);
                    ctx.lineTo(x, s * 0.82);
                    ctx.stroke();
                    ctx.beginPath();
                    ctx.arc(x, knobY, s * 0.07, 0, 2 * Math.PI);
                    ctx.fill();
                };
                drawSlider(s * 0.28, s * 0.65);
                drawSlider(s * 0.50, s * 0.35);
                drawSlider(s * 0.72, s * 0.55);
                break;

            case "volume_up":
            case "volume":
                // Apple Speaker + 2 Waves
                ctx.beginPath();
                ctx.moveTo(s * 0.16, s * 0.38);
                ctx.lineTo(s * 0.28, s * 0.38);
                ctx.lineTo(s * 0.46, s * 0.22);
                ctx.lineTo(s * 0.46, s * 0.78);
                ctx.lineTo(s * 0.28, s * 0.62);
                ctx.lineTo(s * 0.16, s * 0.62);
                ctx.closePath();
                ctx.fill();
                ctx.lineWidth = s * 0.09;
                ctx.beginPath();
                ctx.arc(s * 0.44, s * 0.50, s * 0.20, -Math.PI * 0.30, Math.PI * 0.30);
                ctx.stroke();
                ctx.beginPath();
                ctx.arc(s * 0.44, s * 0.50, s * 0.36, -Math.PI * 0.30, Math.PI * 0.30);
                ctx.stroke();
                break;

            case "volume_down":
                // Apple Speaker + 1 Wave
                ctx.beginPath();
                ctx.moveTo(s * 0.16, s * 0.38);
                ctx.lineTo(s * 0.28, s * 0.38);
                ctx.lineTo(s * 0.46, s * 0.22);
                ctx.lineTo(s * 0.46, s * 0.78);
                ctx.lineTo(s * 0.28, s * 0.62);
                ctx.lineTo(s * 0.16, s * 0.62);
                ctx.closePath();
                ctx.fill();
                ctx.lineWidth = s * 0.09;
                ctx.beginPath();
                ctx.arc(s * 0.44, s * 0.50, s * 0.20, -Math.PI * 0.30, Math.PI * 0.30);
                ctx.stroke();
                break;

            case "volume_off":
            case "volume_mute":
                // Apple Speaker + Cross Mute
                ctx.beginPath();
                ctx.moveTo(s * 0.16, s * 0.38);
                ctx.lineTo(s * 0.28, s * 0.38);
                ctx.lineTo(s * 0.46, s * 0.22);
                ctx.lineTo(s * 0.46, s * 0.78);
                ctx.lineTo(s * 0.28, s * 0.62);
                ctx.lineTo(s * 0.16, s * 0.62);
                ctx.closePath();
                ctx.fill();
                ctx.lineWidth = s * 0.09;
                ctx.beginPath();
                ctx.moveTo(s * 0.60, s * 0.38);
                ctx.lineTo(s * 0.80, s * 0.62);
                ctx.moveTo(s * 0.80, s * 0.38);
                ctx.lineTo(s * 0.60, s * 0.62);
                ctx.stroke();
                break;

            case "cloud_off":
                // Cloud with slash
                ctx.lineWidth = s * 0.085;
                ctx.beginPath();
                ctx.arc(s * 0.44, s * 0.44, s * 0.20, Math.PI, 0);
                ctx.stroke();
                ctx.beginPath();
                ctx.moveTo(s * 0.20, s * 0.80);
                ctx.lineTo(s * 0.80, s * 0.20);
                ctx.stroke();
                break;

            case "delete":
                // Apple Trash
                ctx.lineWidth = s * 0.085;
                ctx.beginPath();
                ctx.moveTo(s * 0.22, s * 0.30);
                ctx.lineTo(s * 0.78, s * 0.30);
                ctx.moveTo(s * 0.40, s * 0.22);
                ctx.lineTo(s * 0.60, s * 0.22);
                ctx.moveTo(s * 0.28, s * 0.30);
                ctx.lineTo(s * 0.32, s * 0.82);
                ctx.lineTo(s * 0.68, s * 0.82);
                ctx.lineTo(s * 0.72, s * 0.30);
                ctx.stroke();
                break;

            case "edit":
                // Apple Pencil / Edit
                ctx.lineWidth = s * 0.09;
                ctx.beginPath();
                ctx.moveTo(s * 0.20, s * 0.80);
                ctx.lineTo(s * 0.34, s * 0.80);
                ctx.lineTo(s * 0.80, s * 0.34);
                ctx.lineTo(s * 0.66, s * 0.20);
                ctx.lineTo(s * 0.20, s * 0.66);
                ctx.closePath();
                ctx.stroke();
                break;

            case "share":
                // Apple Share Sheet: square tray with upward arrow
                ctx.lineWidth = s * 0.09;
                ctx.beginPath();
                ctx.moveTo(s * 0.30, s * 0.38);
                ctx.lineTo(s * 0.20, s * 0.38);
                ctx.lineTo(s * 0.20, s * 0.82);
                ctx.lineTo(s * 0.80, s * 0.82);
                ctx.lineTo(s * 0.80, s * 0.38);
                ctx.lineTo(s * 0.70, s * 0.38);
                ctx.stroke();
                ctx.beginPath();
                ctx.moveTo(s * 0.50, s * 0.60);
                ctx.lineTo(s * 0.50, s * 0.16);
                ctx.lineTo(s * 0.34, s * 0.32);
                ctx.moveTo(s * 0.50, s * 0.16);
                ctx.lineTo(s * 0.66, s * 0.32);
                ctx.stroke();
                break;

            case "podcasts":
                // Concentric circles with antenna stem
                ctx.lineWidth = s * 0.085;
                ctx.beginPath();
                ctx.arc(s * 0.50, s * 0.44, s * 0.34, Math.PI * 0.80, Math.PI * 0.20);
                ctx.stroke();
                ctx.beginPath();
                ctx.arc(s * 0.50, s * 0.44, s * 0.20, Math.PI * 0.80, Math.PI * 0.20);
                ctx.stroke();
                ctx.beginPath();
                ctx.arc(s * 0.50, s * 0.44, s * 0.09, 0, 2 * Math.PI);
                ctx.fill();
                ctx.beginPath();
                ctx.moveTo(s * 0.50, s * 0.53);
                ctx.lineTo(s * 0.50, s * 0.84);
                ctx.stroke();
                break;

            case "info":
                // Apple Info 'i' circle
                ctx.lineWidth = s * 0.095;
                ctx.beginPath();
                ctx.arc(s * 0.5, s * 0.5, s * 0.41, 0, 2 * Math.PI);
                ctx.stroke();
                ctx.beginPath();
                ctx.arc(s * 0.5, s * 0.32, s * 0.05, 0, 2 * Math.PI);
                ctx.fill();
                ctx.beginPath();
                ctx.moveTo(s * 0.5, s * 0.45);
                ctx.lineTo(s * 0.5, s * 0.70);
                ctx.stroke();
                break;

            case "folder_open":
                ctx.lineWidth = s * 0.09;
                ctx.beginPath();
                ctx.moveTo(s * 0.18, s * 0.30);
                ctx.lineTo(s * 0.42, s * 0.30);
                ctx.lineTo(s * 0.50, s * 0.40);
                ctx.lineTo(s * 0.82, s * 0.40);
                ctx.lineTo(s * 0.82, s * 0.74);
                ctx.lineTo(s * 0.18, s * 0.74);
                ctx.closePath();
                ctx.stroke();
                break;

            case "arrow_drop_up":
                ctx.beginPath();
                ctx.moveTo(s * 0.50, s * 0.32);
                ctx.lineTo(s * 0.74, s * 0.68);
                ctx.lineTo(s * 0.26, s * 0.68);
                ctx.closePath();
                ctx.fill();
                break;

            case "arrow_drop_down":
                ctx.beginPath();
                ctx.moveTo(s * 0.26, s * 0.32);
                ctx.lineTo(s * 0.74, s * 0.32);
                ctx.lineTo(s * 0.50, s * 0.68);
                ctx.closePath();
                ctx.fill();
                break;

            default:
                break;
            }
        }
    }

    Sym {
        id: fallbackSym

        anchors.centerIn: parent
        text: root.name
        iconSize: root.size
        color: root.drawColor
        visible: !root.isVector
    }

    onDrawColorChanged: if (isVector) canvas.requestPaint()
    onSizeChanged: if (isVector) canvas.requestPaint()
    onNameChanged: if (isVector) canvas.requestPaint()
}
