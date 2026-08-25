import QtQuick 6.10
import Quickshell
import Quickshell.Io
import "../../../services" as QsServices
import "."

Item {
    id: root
    
    readonly property var pywal: QsServices.Pywal
    readonly property var time: QsServices.Time
    
    implicitWidth: clockText.implicitWidth + 12
    implicitHeight: 28
    
    Process {
        id: openCalendarProc
        command: ["zen-browser", "https://calendar.google.com"]
    }
    
    Text {
        id: clockText
        anchors.centerIn: parent
        text: "󰥔 " + time.format("ddd, dd. MMM hh:mm AP")
        font.family: "JetBrainsMono Nerd Font Propo"
        font.pixelSize: 15
        color: clockMouse.containsMouse ? pywal.color1 : "white"
        
        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }
    
    MouseArea {
        id: clockMouse
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        
        onClicked: {
            openCalendarProc.running = true;
        }
    }
    
    // Calendar tooltip on hover
    ClockCalendar {
        id: calendarPopup
        anchors.top: parent.bottom
        anchors.topMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        visible: clockMouse.containsMouse || calMouse.containsMouse
        z: 9999
        
        MouseArea {
            id: calMouse
            anchors.fill: parent
            hoverEnabled: true
        }
    }
}
