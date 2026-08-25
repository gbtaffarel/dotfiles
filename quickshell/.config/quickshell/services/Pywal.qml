pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick 6.10

Singleton {
    id: root
    
    // Pywal color properties matching ~/.cache/wal/colors.json
    property color background: "#0a0a17"
    property color foreground: "#c1c1c5"
    property color cursor: "#c1c1c5"
    
    // Individual color properties from pywal
    property color color0: "#0a0a17"
    property color color1: "#993D42"
    property color color2: "#925C77"
    property color color3: "#6B7886"
    property color color4: "#996385"
    property color color5: "#A97489"
    property color color6: "#3F958D"
    property color color7: "#c1c1c5"
    property color color8: "#59596d"
    property color color9: "#993D42"
    property color color10: "#925C77"
    property color color11: "#6B7886"
    property color color12: "#996385"
    property color color13: "#A97489"
    property color color14: "#3F958D"
    property color color15: "#c1c1c5"
    
    // Semantic tokens
    readonly property color primary: color1
    readonly property color secondary: color2
    readonly property color surface: background
    readonly property color surfaceContainer: color8
    readonly property color onSurface: foreground
    
    function loadColors(text: string): void {
        if (!text || text.trim().length === 0) return;
        try {
            const data = JSON.parse(text);
            if (data.special) {
                if (data.special.background) root.background = data.special.background;
                if (data.special.foreground) root.foreground = data.special.foreground;
                if (data.special.cursor) root.cursor = data.special.cursor;
            }
            if (data.colors) {
                if (data.colors.color0) root.color0 = data.colors.color0;
                if (data.colors.color1) root.color1 = data.colors.color1;
                if (data.colors.color2) root.color2 = data.colors.color2;
                if (data.colors.color3) root.color3 = data.colors.color3;
                if (data.colors.color4) root.color4 = data.colors.color4;
                if (data.colors.color5) root.color5 = data.colors.color5;
                if (data.colors.color6) root.color6 = data.colors.color6;
                if (data.colors.color7) root.color7 = data.colors.color7;
                if (data.colors.color8) root.color8 = data.colors.color8;
                if (data.colors.color9) root.color9 = data.colors.color9;
                if (data.colors.color10) root.color10 = data.colors.color10;
                if (data.colors.color11) root.color11 = data.colors.color11;
                if (data.colors.color12) root.color12 = data.colors.color12;
                if (data.colors.color13) root.color13 = data.colors.color13;
                if (data.colors.color14) root.color14 = data.colors.color14;
                if (data.colors.color15) root.color15 = data.colors.color15;
            }
            console.log("🎨 Pywal colors loaded successfully");
        } catch (e) {
            console.error("Failed to parse pywal colors:", e);
        }
    }
    
    // Load colors from user's pywal cache
    FileView {
        id: pywalFile
        path: (Quickshell.env("HOME") || "/home/gabriel") + "/.cache/wal/colors.json"
        watchChanges: true
        onLoaded: root.loadColors(text())
        onFileChanged: root.loadColors(text())
    }
    
    Component.onCompleted: {
        if (pywalFile.text()) {
            root.loadColors(pywalFile.text());
        }
    }
}
