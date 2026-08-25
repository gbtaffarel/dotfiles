import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell
import "components" as BarComponents
import "../../services" as QsServices

Item {
    id: root
    
    property var screen
    property var barWindow
    
    readonly property var pywal: QsServices.Pywal
    
    // Bar Background: alpha(@background, 0.7)
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(pywal.background.r, pywal.background.g, pywal.background.b, 0.7)
    }
    
    // ═══════════════════════════════════════════════════════════════
    // LEFT MODULES - Workspaces + Media Group
    // ═══════════════════════════════════════════════════════════════
    Row {
        id: leftSection
        anchors.left: parent.left
        anchors.leftMargin: 7
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0
        
        // Hyprland Workspaces
        BarComponents.Workspaces {
            id: workspacesModule
            screen: root.screen
            anchors.verticalCenter: parent.verticalCenter
        }
        
        // Spacer: 80px margin matching Waybar #media { margin: 7px 0px 7px 80px; }
        Item {
            width: 80
            height: 1
            visible: mediaModule.visible
        }
        
        // Media Controls Group
        BarComponents.MediaPlayer {
            id: mediaModule
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    
    // ═══════════════════════════════════════════════════════════════
    // CENTER MODULE - Clock with Calendar
    // ═══════════════════════════════════════════════════════════════
    BarComponents.Clock {
        id: centerSection
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }
    
    // ═══════════════════════════════════════════════════════════════
    // RIGHT MODULES - Tray, Submap, Volume, Battery, Bluetooth, Network, CPU, Memory
    // ═══════════════════════════════════════════════════════════════
    Row {
        id: rightSection
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10
        
        // 1. System Tray
        BarComponents.SystemTray {
            barWindow: root.barWindow
            anchors.verticalCenter: parent.verticalCenter
        }
        
        // 2. Hyprland Submap (e.g. resize)
        BarComponents.Submap {
            anchors.verticalCenter: parent.verticalCenter
        }
        
        // 3. Volume + Slider
        BarComponents.Volume {
            anchors.verticalCenter: parent.verticalCenter
        }
        
        // 4. Battery
        BarComponents.Battery {
            anchors.verticalCenter: parent.verticalCenter
        }
        
        // 5. Bluetooth
        BarComponents.Bluetooth {
            anchors.verticalCenter: parent.verticalCenter
        }
        
        // 6. Network
        BarComponents.Network {
            anchors.verticalCenter: parent.verticalCenter
        }
        
        // 7. CPU & Temperature
        BarComponents.CpuTemp {
            anchors.verticalCenter: parent.verticalCenter
        }
        
        // 8. Memory
        BarComponents.Memory {
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
