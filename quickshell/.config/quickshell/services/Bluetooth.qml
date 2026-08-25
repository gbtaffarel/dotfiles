pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick 6.10

Singleton {
    id: root
    
    property bool powered: false
    property bool connected: false
    property int numConnections: 0
    property string controllerAlias: "archlinux"
    property string controllerAddress: ""
    property var connectedDevices: []
    
    readonly property string displayText: {
        if (!powered) return "";
        if (connected && numConnections > 0) {
            return " " + numConnections;
        }
        return "";
    }

    readonly property string tooltipText: {
        let text = controllerAlias + (controllerAddress ? "\t" + controllerAddress : "");
        if (connected && connectedDevices.length > 0) {
            text += "\n\n";
            for (let i = 0; i < connectedDevices.length; i++) {
                const dev = connectedDevices[i];
                text += (i > 0 ? "\n" : "") + dev.alias + "\t" + dev.address;
            }
        }
        return text;
    }
    
    // Check status periodically
    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            statusProc.running = true;
            if (root.powered) {
                connectedProc.running = true;
            }
        }
    }
    
    Process {
        id: statusProc
        command: ["bluetoothctl", "show"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.powered = text.includes("Powered: yes");
                const aliasMatch = text.match(/Alias: (.*)/);
                if (aliasMatch) root.controllerAlias = aliasMatch[1].trim();
                const addrMatch = text.match(/Controller ([0-9A-Fa-f:]{17})/);
                if (addrMatch) root.controllerAddress = addrMatch[1].trim();
            }
        }
    }
    
    onPoweredChanged: {
        if (powered) {
            connectedProc.running = true;
        } else {
            connected = false;
            numConnections = 0;
            connectedDevices = [];
        }
    }
    
    Process {
        id: connectedProc
        command: ["bluetoothctl", "devices", "Connected"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n").filter(l => l.trim().length > 0);
                const devs = [];
                for (let i = 0; i < lines.length; i++) {
                    const line = lines[i].trim();
                    if (line.startsWith("Device")) {
                        const parts = line.split(/\s+/);
                        if (parts.length >= 3) {
                            const addr = parts[1];
                            const alias = parts.slice(2).join(" ");
                            devs.push({ address: addr, alias: alias });
                        }
                    }
                }
                root.connectedDevices = devs;
                root.numConnections = devs.length;
                root.connected = devs.length > 0;
            }
        }
    }
    
    function togglePower(): void {
        const cmd = powered ? "power off" : "power on";
        toggleProc.command = ["bluetoothctl", cmd];
        toggleProc.running = true;
    }
    
    Process {
        id: toggleProc
        onExited: statusProc.running = true
    }
}
