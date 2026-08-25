//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

import Quickshell
import QtQuick 6.10
import "services" as QsServices

ShellRoot {
    id: root
    
    // Initialize services
    readonly property var pywal: QsServices.Pywal
    readonly property var hypr: QsServices.Hypr
    readonly property var audio: QsServices.Audio
    readonly property var players: QsServices.Players
    readonly property var sys: QsServices.SystemUsage
    readonly property var bt: QsServices.Bluetooth
    readonly property var net: QsServices.Network
    
    // Main Waybar-equivalent bar
    Loader {
        id: barLoader
        source: "modules/bar/BarWrapper.qml"
    }

    Component.onCompleted: {
        console.log("⚡ Quickshell Waybar replacement loaded successfully!")
    }
}
