import QtQuick 6.10
import Quickshell
import Quickshell.Io
import "../../../services" as QsServices

Rectangle {
    id: root
    
    readonly property var pywal: QsServices.Pywal
    readonly property var sys: QsServices.SystemUsage
    
    implicitWidth: memText.implicitWidth + 16
    implicitHeight: 28
    radius: 8
    color: pywal.color8
    
    Process {
        id: htopProc
        command: ["kitty", "--title=htop", "-e", "htop"]
    }
    
    Text {
        id: memText
        anchors.centerIn: parent
        text: " " + sys.memPercentage + "%"
        font.family: "JetBrainsMono Nerd Font Propo"
        font.pixelSize: 15
        color: "white"
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: htopProc.running = true
    }
    
    StyledTooltip {
        anchors.top: parent.bottom
        anchors.topMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        text: sys.memTooltip
        visible: mouseArea.containsMouse && text.length > 0
    }
}
