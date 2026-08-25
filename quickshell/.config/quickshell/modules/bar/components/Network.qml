import QtQuick 6.10
import Quickshell
import Quickshell.Io
import "../../../services" as QsServices

Rectangle {
    id: root
    
    readonly property var pywal: QsServices.Pywal
    readonly property var net: QsServices.Network
    
    implicitWidth: netText.implicitWidth + 16
    implicitHeight: 28
    radius: 8
    color: pywal.color8
    
    Process {
        id: nmrsProc
        command: ["nmrs"]
    }
    
    Text {
        id: netText
        anchors.centerIn: parent
        text: net.icon
        font.family: "JetBrainsMono Nerd Font Propo"
        font.pixelSize: 15
        color: "white"
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: nmrsProc.running = true
    }
    
    StyledTooltip {
        anchors.top: parent.bottom
        anchors.topMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        text: net.tooltipText
        visible: mouseArea.containsMouse && text.length > 0
    }
}
