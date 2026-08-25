import QtQuick 6.10
import Quickshell
import Quickshell.Services.UPower
import "../../../services" as QsServices

Rectangle {
    id: root
    
    readonly property var pywal: QsServices.Pywal
    readonly property var battery: UPower.displayDevice
    
    readonly property int capacity: {
        if (!battery) return 100;
        const pct = battery.percentage;
        return Math.round(pct > 1 ? pct : pct * 100);
    }
    
    readonly property bool isCharging: {
        if (!battery) return false;
        return battery.state === UPowerDeviceState.Charging || battery.state === UPowerDeviceState.FullyCharged;
    }
    
    readonly property var defaultIcons: ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
    readonly property var chargingIcons: ["󰢟", "󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]
    
    readonly property string icon: {
        const idx = Math.min(10, Math.max(0, Math.floor(capacity / 10)));
        return isCharging ? chargingIcons[idx] : defaultIcons[idx];
    }
    
    implicitWidth: batText.implicitWidth + 16
    implicitHeight: 28
    radius: 8
    color: pywal.color8
    
    Text {
        id: batText
        anchors.centerIn: parent
        text: root.capacity + "% " + root.icon
        font.family: "JetBrainsMono Nerd Font Propo"
        font.pixelSize: 15
        color: "white"
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }
    
    StyledTooltip {
        anchors.top: parent.bottom
        anchors.topMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.capacity + "% - " + (root.isCharging ? "Carregando" : "Bateria")
        visible: mouseArea.containsMouse
    }
}
