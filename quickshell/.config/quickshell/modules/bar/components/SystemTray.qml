import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../../../services" as QsServices

Rectangle {
    id: root
    
    readonly property var pywal: QsServices.Pywal
    readonly property bool hasItems: SystemTray.items.values.length > 0
    
    implicitWidth: rowLayout.implicitWidth + 16
    implicitHeight: 28
    radius: 8
    color: pywal.color8
    visible: hasItems
    
    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: 8
        
        Repeater {
            model: SystemTray.items.values
            
            delegate: Item {
                id: trayItem
                required property var modelData
                
                implicitWidth: 18
                implicitHeight: 18
                
                IconImage {
                    anchors.fill: parent
                    source: trayItem.modelData.icon || ""
                }
                
                QsMenuAnchor {
                    id: menuAnchor
                    menu: trayItem.modelData.hasMenu ? trayItem.modelData.menu : null
                    anchor.item: trayItem
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    hoverEnabled: true
                    
                    onClicked: mouse => {
                        if (mouse.button === Qt.LeftButton) {
                            if (trayItem.modelData.onlyMenu && trayItem.modelData.hasMenu) {
                                menuAnchor.open();
                            } else {
                                trayItem.modelData.activate();
                            }
                        } else if (mouse.button === Qt.RightButton) {
                            if (trayItem.modelData.hasMenu) {
                                menuAnchor.open();
                            } else {
                                trayItem.modelData.secondaryActivate();
                            }
                        } else if (mouse.button === Qt.MiddleButton) {
                            trayItem.modelData.secondaryActivate();
                        }
                    }
                    
                    onWheel: wheel => {
                        trayItem.modelData.scroll(wheel.angleDelta.y, false);
                    }
                }
            }
        }
    }
}
