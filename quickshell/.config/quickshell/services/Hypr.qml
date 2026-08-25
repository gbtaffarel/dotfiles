pragma Singleton

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick 6.10

Singleton {
    id: root

    readonly property var toplevels: Hyprland.toplevels
    readonly property var workspaces: Hyprland.workspaces
    readonly property var monitors: Hyprland.monitors

    readonly property var activeToplevel: Hyprland.activeToplevel
    readonly property var focusedWorkspace: Hyprland.focusedWorkspace
    readonly property var focusedMonitor: Hyprland.focusedMonitor
    readonly property int activeWsId: focusedWorkspace?.id ?? 1
    property string currentSubmap: ""

    Process {
        id: execDispatchProc
    }

    function dispatch(request: string): void {
        Hyprland.dispatch(request);
    }

    function switchToWorkspace(wsId: var): void {
        if (Hyprland.usingLua) {
            Hyprland.dispatch("hl.dsp.focus({ workspace = " + wsId + " })");
        } else {
            Hyprland.dispatch("workspace " + wsId);
        }
    }

    function scrollWorkspace(delta: int): void {
        const dir = delta > 0 ? "e-1" : "e+1";
        if (Hyprland.usingLua) {
            Hyprland.dispatch("hl.dsp.focus({ workspace = '" + dir + "' })");
        } else {
            Hyprland.dispatch("workspace " + dir);
        }
    }

    function monitorFor(screen: var): var {
        return Hyprland.monitorFor(screen);
    }

    // Get occupied workspaces (workspaces with windows)
    function getOccupiedWorkspaces(): var {
        const occupied = {};
        for (const ws of workspaces.values) {
            occupied[ws.id] = (ws.lastIpcObject?.windows ?? 0) > 0;
        }
        return occupied;
    }

    // Refresh timer to ensure updates when events are missed
    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            Hyprland.refreshWorkspaces();
        }
    }

    Connections {
        target: Hyprland

        function onRawEvent(event: var): void {
            const n = event.name;
            if (n === "submap") {
                const sub = event.data?.trim() ?? "";
                root.currentSubmap = (sub === "default" || sub === "") ? "" : sub;
                return;
            }
            if (n.endsWith("v2"))
                return;

            // More aggressive refresh for workspace changes
            if (["workspace", "moveworkspace", "activespecial", "focusedmon", "activewindow"].includes(n)) {
                Hyprland.refreshWorkspaces();
                Hyprland.refreshMonitors();
            } else if (["openwindow", "closewindow", "movewindow"].includes(n)) {
                Hyprland.refreshToplevels();
                Hyprland.refreshWorkspaces();
            } else if (n.includes("workspace")) {
                Hyprland.refreshWorkspaces();
            } else if (n.includes("window")) {
                Hyprland.refreshToplevels();
                Hyprland.refreshWorkspaces();
            }
        }
    }
}
