import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell
import Quickshell.Io
import "../../../services" as QsServices

Rectangle {
    id: root
    
    readonly property var pywal: QsServices.Pywal
    readonly property var audio: QsServices.Audio
    
    implicitWidth: rowLayout.implicitWidth + 16
    implicitHeight: 28
    radius: 8
    color: pywal.color8
    
    Process {
        id: pavuProc
        command: ["pavucontrol"]
    }
    
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        
        onWheel: wheel => {
            if (wheel.angleDelta.y > 0) {
                audio.increaseVolume();
            } else if (wheel.angleDelta.y < 0) {
                audio.decreaseVolume();
            }
        }
    }
    
    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: 8
        
        // Volume label & icon
        Item {
            implicitWidth: volText.implicitWidth
            implicitHeight: 20
            
            Text {
                id: volText
                anchors.centerIn: parent
                text: audio.muted ? "" : (audio.percentage + "% " + audio.icon)
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 15
                color: "white"
            }
            
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                
                onClicked: mouse => {
                    if (mouse.button === Qt.LeftButton) {
                        pavuProc.running = true;
                    } else if (mouse.button === Qt.MiddleButton) {
                        audio.toggleMute();
                    }
                }
            }
        }
        
        // Pulseaudio Slider
        Item {
            id: sliderContainer
            implicitWidth: 75
            implicitHeight: 16
            
            // Trough
            Rectangle {
                id: trough
                anchors.verticalCenter: parent.verticalCenter
                width: 75
                height: 8
                radius: 5
                color: pywal.color2
                
                // Highlight / Filled portion
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: Math.max(8, Math.min(parent.width, (audio.volume) * parent.width))
                    radius: 5
                    color: pywal.color1
                }
            }
            
            MouseArea {
                id: sliderMouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                
                function updateFromMouse(mouseX) {
                    const norm = Math.max(0, Math.min(1.0, mouseX / trough.width));
                    audio.setVolume(norm);
                }
                
                onPressed: mouse => updateFromMouse(mouse.x)
                onPositionChanged: mouse => {
                    if (pressed) {
                        updateFromMouse(mouse.x);
                    }
                }
            }
        }
    }
}
