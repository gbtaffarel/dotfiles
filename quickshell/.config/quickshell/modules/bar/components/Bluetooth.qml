import QtQuick 6.10
import Quickshell
import Quickshell.Io
import "../../../services" as QsServices

Rectangle {
    id: root
    
    readonly property var pywal: QsServices.Pywal
    readonly property var bt: QsServices.Bluetooth
    
    implicitWidth: btText.implicitWidth + 16
    implicitHeight: 28
    radius: 8
    color: pywal.color8
    visible: bt.displayText !== ""
    
    Process {
        id: bluetuiProc
        command: ["kitty", "--title=bluetui", "-e", "bluetui"]
    }
    
    Text {
        id: btText
        anchors.centerIn: parent
        text: bt.displayText
        font.family: "JetBrainsMono Nerd Font Propo"
        font.pixelSize: 15
        color: "white"
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: bluetuiProc.running = true
    }
    
    StyledTooltip {
        anchors.top: parent.bottom
        anchors.topMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        text: bt.tooltipText
        visible: mouseArea.containsMouse && text.length > 0
    }
}
