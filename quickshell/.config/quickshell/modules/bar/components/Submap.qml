import QtQuick 6.10
import Quickshell
import "../../../services" as QsServices

Rectangle {
    id: root
    
    readonly property var hypr: QsServices.Hypr
    readonly property bool hasSubmap: hypr.currentSubmap !== ""
    
    implicitWidth: submapText.implicitWidth + 16
    implicitHeight: 28
    radius: 8
    color: "#e35149"
    visible: hasSubmap
    
    Text {
        id: submapText
        anchors.centerIn: parent
        text: hypr.currentSubmap.toUpperCase()
        font.family: "JetBrainsMono Nerd Font Propo"
        font.pixelSize: 14
        font.bold: true
        color: "black"
    }
}
