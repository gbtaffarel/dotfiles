import QtQuick 6.10
import Quickshell
import Quickshell.Io
import "../../../services" as QsServices

Rectangle {
    id: root
    
    readonly property var pywal: QsServices.Pywal
    readonly property var sys: QsServices.SystemUsage
    
    implicitWidth: cpuText.implicitWidth + 16
    implicitHeight: 28
    radius: 8
    color: pywal.color8
    
    Process {
        id: btopProc
        command: ["kitty", "--title=btop", "-e", "btop"]
    }
    
    Text {
        id: cpuText
        anchors.centerIn: parent
        text: " " + sys.cpuPercentage + "% | " + sys.cpuTemperature + "°C"
        font.family: "JetBrainsMono Nerd Font Propo"
        font.pixelSize: 15
        color: "white"
    }
    
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: btopProc.running = true
    }
}
