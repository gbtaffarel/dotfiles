import Quickshell
import QtQuick 6.10
import QtQuick.Layouts 6.10
import "../../../services" as QsServices

Item {
    id: root
    
    property var screen
    
    readonly property var pywal: QsServices.Pywal
    readonly property var hypr: QsServices.Hypr
    
    // Determine active workspace on this monitor
    readonly property var currentMonitor: hypr.monitorFor(screen)
    readonly property int activeWsId: currentMonitor?.activeWorkspace?.id ?? hypr.activeWsId
    
    // Workspaces model: at least 1..5 (persistent-workspaces: 5), plus any higher active/occupied workspace
    readonly property var workspaceList: {
        const list = [1, 2, 3, 4, 5];
        const allWs = hypr.workspaces?.values ?? [];
        for (let i = 0; i < allWs.length; i++) {
            const id = allWs[i].id;
            if (id > 5 && !list.includes(id)) {
                list.push(id);
            }
        }
        if (activeWsId > 5 && !list.includes(activeWsId)) {
            list.push(activeWsId);
        }
        list.sort((a, b) => a - b);
        return list;
    }
    
    implicitWidth: rowLayout.implicitWidth
    implicitHeight: 28
    
    // Wheel mouse area with acceptedButtons: Qt.NoButton so clicks pass through!
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        hoverEnabled: false
        onWheel: wheel => {
            if (wheel.angleDelta.y > 0) {
                hypr.scrollWorkspace(1);
            } else if (wheel.angleDelta.y < 0) {
                hypr.scrollWorkspace(-1);
            }
        }
    }
    
    RowLayout {
        id: rowLayout
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4
        
        Repeater {
            model: root.workspaceList
            
            delegate: Rectangle {
                id: wsButton
                
                required property int modelData
                required property int index
                
                readonly property int wsId: modelData
                readonly property bool isActive: root.activeWsId === wsId
                readonly property bool isUrgent: {
                    const wsObj = (hypr.workspaces?.values ?? []).find(w => w.id === wsId);
                    return wsObj?.urgent ?? false;
                }
                
                implicitWidth: Math.max(26, wsText.implicitWidth + 12)
                implicitHeight: 26
                radius: 2
                
                // Waybar CSS:
                // #workspaces button { padding: 3px; margin: 7px 0px 7px 7px; background: transparent; border-radius: 2px; color: white; }
                // #workspaces button.active { background: @color1; color: @color0; font-weight: 700; }
                // #workspaces button.urgent { background: rgba(227, 81, 73, 1); color: black; }
                color: isUrgent ? "#e35149" : (isActive ? pywal.color1 : "transparent")
                
                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
                
                Text {
                    id: wsText
                    anchors.centerIn: parent
                    text: wsButton.wsId.toString()
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 15
                    font.bold: wsButton.isActive
                    color: wsButton.isUrgent ? "black" : (wsButton.isActive ? pywal.color0 : "white")
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: {
                        hypr.switchToWorkspace(wsButton.wsId);
                    }
                }
            }
        }
    }
}
