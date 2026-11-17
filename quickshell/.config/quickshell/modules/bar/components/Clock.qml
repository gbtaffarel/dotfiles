import QtQuick 6.10
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../../../services" as QsServices

Item {
    id: root
    
    property var barWindow: null
    
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
        text: time.format("hh:mm")
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
    
    // Date tooltip window on hover (centered below the clock)
    PanelWindow {
        id: datePopup
        screen: root.barWindow ? root.barWindow.screen : Quickshell.screens[0]
        
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell-clock-tooltip"
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        
        anchors {
            top: true
        }
        
        margins {
            top: 37
        }
        
        color: "transparent"
        implicitWidth: tooltipCard.implicitWidth
        implicitHeight: tooltipCard.implicitHeight
        visible: clockMouse.containsMouse
        
        Rectangle {
            id: tooltipCard
            implicitWidth: label.implicitWidth + 24
            implicitHeight: label.implicitHeight + 14
            width: implicitWidth
            height: implicitHeight
            radius: 6
            color: Qt.rgba(pywal.color8.r, pywal.color8.g, pywal.color8.b, 0.95)
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.15)
            
            Text {
                id: label
                anchors.centerIn: parent
                text: {
                    var raw = time.formatLocalized("dddd, d 'de' MMMM 'de' yyyy", Qt.locale("pt_BR"));
                    return raw ? (raw.charAt(0).toUpperCase() + raw.slice(1)) : "";
                }
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 13
                color: "white"
            }
        }
    }
}
