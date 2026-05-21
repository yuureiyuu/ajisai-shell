pragma ComponentBehavior: Bound
pragma Singleton

import QtQml
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    readonly property bool hasBrowserBridge: Mpris.players.values.some(player =>
        player.dbusName?.startsWith("org.mpris.MediaPlayer2.plasma-browser-integration")
    )
    readonly property list<MprisPlayer> players: Mpris.players.values.filter(player => root.isUsefulPlayer(player))
    property MprisPlayer trackedPlayer: null
    readonly property MprisPlayer activePlayer: trackedPlayer ?? players[0] ?? null

    readonly property string player: activePlayer?.identity ?? ""
    readonly property string artist: activePlayer?.trackArtist ?? ""
    readonly property string title: activePlayer?.trackTitle ?? ""
    readonly property string album: activePlayer?.trackAlbum ?? ""
    readonly property bool isPlaying: activePlayer?.isPlaying ?? false
    readonly property string displayText: {
        if (!title.length)
            return "Nothing is playing";
        if (artist.length)
            return `${artist} - ${title}`;
        return title;
    }

    function isUsefulPlayer(player) {
        if (!player)
            return false;

        if (player.dbusName?.startsWith("org.mpris.MediaPlayer2.playerctld"))
            return false;

        if (!hasBrowserBridge)
            return true;

        return !(player.dbusName?.startsWith("org.mpris.MediaPlayer2.firefox")
            || player.dbusName?.startsWith("org.mpris.MediaPlayer2.chromium")
            || player.dbusName?.startsWith("org.mpris.MediaPlayer2.brave")
            || player.dbusName?.startsWith("org.mpris.MediaPlayer2.google-chrome"));
    }

    function pickPlayer() {
        for (const player of players) {
            if (player?.isPlaying)
                return player;
        }

        return players.length ? players[0] : null;
    }

    function refresh() {
        trackedPlayer = pickPlayer();
    }

    Instantiator {
        model: Mpris.players

        Connections {
            required property MprisPlayer modelData
            target: modelData

            Component.onCompleted: root.refresh()
            Component.onDestruction: root.refresh()

            function onPlaybackStateChanged() {
                root.refresh();
            }

            function onPostTrackChanged() {
                root.refresh();
            }
        }
    }

    Connections {
        target: Mpris.players

        function onValuesChanged() {
            root.refresh();
        }
    }
}
