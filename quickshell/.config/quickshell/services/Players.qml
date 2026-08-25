pragma Singleton

import Quickshell
import Quickshell.Services.Mpris
import QtQuick 6.10

Singleton {
    id: root

    // Filtered list of valid players (exclude kdeconnect and playerctld)
    readonly property var rawList: Mpris.players.values
    readonly property var list: {
        const valid = [];
        for (let i = 0; i < rawList.length; i++) {
            const p = rawList[i];
            if (!p) continue;
            const id = (p.identity || p.desktopEntry || "").toLowerCase();
            if (id.includes("kdeconnect") || id.includes("playerctld")) continue;
            valid.push(p);
        }
        return valid;
    }
    
    property int selectedIndex: 0
    
    // Active player: selected player if valid, or first playing player, or first valid player
    property var active: {
        if (list.length === 0) return null;
        if (selectedIndex >= 0 && selectedIndex < list.length) {
            return list[selectedIndex];
        }
        for (let i = 0; i < list.length; i++) {
            if (list[i]?.isPlaying) {
                return list[i];
            }
        }
        return list[0] ?? null;
    }

    readonly property bool hasPlayer: active !== null
    readonly property bool isPlaying: active?.isPlaying ?? false
    readonly property string title: active?.trackTitle ?? ""
    readonly property string artist: active?.trackArtist ?? active?.trackArtists ?? ""
    readonly property string album: active?.trackAlbum ?? ""
    readonly property string identity: active?.identity ?? active?.desktopEntry ?? ""

    readonly property string playerIcon: {
        const id = identity.toLowerCase();
        if (id.includes("spotify")) return "";
        if (id.includes("firefox") || id.includes("zen")) return "󰈹";
        if (id.includes("chrome") || id.includes("chromium")) return "";
        if (id.includes("mpv")) return "󰐹";
        if (id.includes("vlc")) return "󰕼";
        return "";
    }

    readonly property string statusIcon: isPlaying ? "" : ""

    readonly property string formattedText: {
        if (!active) return "";
        const icon = playerIcon;
        if (title && artist) {
            return icon + " " + title + " - " + artist;
        } else if (title) {
            return icon + " " + title;
        } else if (identity) {
            return icon + " " + identity;
        }
        return icon + " Unknown Media";
    }

    function playPause(): void {
        if (active) {
            if (active.canTogglePlaying) {
                active.togglePlaying();
            } else if (active.isPlaying) {
                active.pause();
            } else {
                active.play();
            }
        }
    }

    function next(): void {
        if (active && active.canGoNext) {
            active.next();
        }
    }

    function previous(): void {
        if (active && active.canGoPrevious) {
            active.previous();
        }
    }

    function switchNext(): void {
        if (list.length <= 1) return;
        selectedIndex = (selectedIndex + 1) % list.length;
    }

    function switchPrev(): void {
        if (list.length <= 1) return;
        selectedIndex = (selectedIndex - 1 + list.length) % list.length;
    }

    function seek(seconds: real): void {
        if (active && active.canSeek) {
            const newPos = Math.max(0, (active.position || 0) + seconds);
            active.position = newPos;
        }
    }
}
