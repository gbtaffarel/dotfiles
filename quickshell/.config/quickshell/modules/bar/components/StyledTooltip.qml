import QtQuick 6.10
import "../../../services" as QsServices

Rectangle {
    id: root
    
    property string text: ""
    
    readonly property var pywal: QsServices.Pywal
    
    implicitWidth: label.implicitWidth + 16
    implicitHeight: label.implicitHeight + 10
    radius: 5
    color: Qt.rgba(pywal.color8.r, pywal.color8.g, pywal.color8.b, 0.95)
    border.width: 1
    border.color: Qt.rgba(1, 1, 1, 0.15)
    z: 9999
    
    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        font.family: "JetBrainsMono Nerd Font Propo"
        font.pixelSize: 13
        color: "white"
        wrapMode: Text.NoWrap
    }
}
