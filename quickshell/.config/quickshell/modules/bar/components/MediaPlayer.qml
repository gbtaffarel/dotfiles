import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell
import "../../../services" as QsServices

Item {
    id: root
    
    readonly property var pywal: QsServices.Pywal
    readonly property var players: QsServices.Players
    readonly property bool hasMedia: players.hasPlayer && players.formattedText.length > 0
    
    implicitWidth: rowLayout.implicitWidth
    implicitHeight: 28
    visible: hasMedia
    
    RowLayout {
        id: rowLayout
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2
        
        // 1. Previous button: 
        Rectangle {
            id: prevBtn
            implicitWidth: prevText.implicitWidth + 8
            implicitHeight: 24
            color: "transparent"
            
            property bool isHovered: prevMouse.containsMouse
            
            Text {
                id: prevText
                anchors.centerIn: parent
                text: ""
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 15
                color: prevBtn.isHovered ? pywal.color1 : pywal.color5
                
                Behavior on color { ColorAnimation { duration: 150 } }
            }
            
            MouseArea {
                id: prevMouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: players.previous()
            }
        }
        
        // 2. Play/Pause button:  / 
        Rectangle {
            id: playBtn
            implicitWidth: playText.implicitWidth + 8
            implicitHeight: 24
            color: "transparent"
            
            property bool isHovered: playMouse.containsMouse
            
            Text {
                id: playText
                anchors.centerIn: parent
                text: players.statusIcon
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 15
                color: playBtn.isHovered ? pywal.color1 : pywal.color5
                
                Behavior on color { ColorAnimation { duration: 150 } }
            }
            
            MouseArea {
                id: playMouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: players.playPause()
            }
        }
        
        // 3. Next button: 
        Rectangle {
            id: nextBtn
            implicitWidth: nextText.implicitWidth + 8
            implicitHeight: 24
            color: "transparent"
            
            property bool isHovered: nextMouse.containsMouse
            
            Text {
                id: nextText
                anchors.centerIn: parent
                text: ""
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 15
                color: nextBtn.isHovered ? pywal.color1 : pywal.color5
                
                Behavior on color { ColorAnimation { duration: 150 } }
            }
            
            MouseArea {
                id: nextMouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: players.next()
            }
        }
        
        // 4. Switch Player button: 
        Rectangle {
            id: switchBtn
            implicitWidth: switchText.implicitWidth + 8
            implicitHeight: 24
            color: "transparent"
            
            property bool isHovered: switchMouse.containsMouse
            
            Text {
                id: switchText
                anchors.centerIn: parent
                text: ""
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 15
                color: switchBtn.isHovered ? pywal.color1 : pywal.color5
                
                Behavior on color { ColorAnimation { duration: 150 } }
            }
            
            MouseArea {
                id: switchMouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: mouse => {
                    if (mouse.button === Qt.LeftButton) {
                        players.switchNext();
                    } else if (mouse.button === Qt.RightButton) {
                        players.switchPrev();
                    }
                }
            }
        }
        
        // 5. Media Text Display with marquee / scrolling
        Item {
            id: textContainer
            implicitWidth: Math.min(260, mediaText.implicitWidth + 12)
            implicitHeight: 24
            clip: true
            
            property bool isHovered: textMouse.containsMouse
            readonly property bool needsMarquee: mediaText.implicitWidth > 260
            
            Text {
                id: mediaText
                anchors.verticalCenter: parent.verticalCenter
                x: 6
                text: players.formattedText
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 15
                color: textContainer.isHovered ? pywal.color1 : pywal.color5
                
                Behavior on color { ColorAnimation { duration: 150 } }
                
                NumberAnimation on x {
                    id: marqueeAnimation
                    running: textContainer.needsMarquee && (players.isPlaying || textContainer.isHovered)
                    loops: Animation.Infinite
                    from: 6
                    to: -(mediaText.implicitWidth - 240)
                    duration: Math.max(3000, (mediaText.implicitWidth - 240) * 40)
                    easing.type: Easing.Linear
                }
            }
            
            MouseArea {
                id: textMouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                
                onClicked: mouse => {
                    if (mouse.button === Qt.LeftButton) {
                        players.playPause();
                    } else if (mouse.button === Qt.RightButton) {
                        players.switchNext();
                    } else if (mouse.button === Qt.MiddleButton) {
                        players.switchPrev();
                    }
                }
                
                onWheel: wheel => {
                    if (wheel.angleDelta.y > 0) {
                        players.seek(5);
                    } else if (wheel.angleDelta.y < 0) {
                        players.seek(-5);
                    }
                }
            }
        }
    }
}
