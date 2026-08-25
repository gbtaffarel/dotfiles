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
    
    // Transparent overlay when any menu is open to catch outside clicks
    MouseArea {
        id: outsideDismissArea
        parent: root.parent
        anchors.fill: parent
        z: 99998
        visible: false
        hoverEnabled: false
        onClicked: {
            visible = false;
        }
    }
    
    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: 8
        
        Repeater {
            model: SystemTray.items.values
            
            delegate: Item {
                id: trayItem
                required property var modelData
                
                property bool isMenuOpen: false
                
                onIsMenuOpenChanged: {
                    if (isMenuOpen) {
                        outsideDismissArea.visible = true;
                    }
                }
                
                implicitWidth: 18
                implicitHeight: 18
                
                IconImage {
                    anchors.fill: parent
                    source: trayItem.modelData.icon || ""
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    hoverEnabled: true
                    
                    onClicked: mouse => {
                        if (mouse.button === Qt.LeftButton) {
                            if (trayItem.modelData.onlyMenu && trayItem.modelData.hasMenu) {
                                trayItem.isMenuOpen = !trayItem.isMenuOpen;
                            } else {
                                trayItem.modelData.activate();
                            }
                        } else if (mouse.button === Qt.RightButton) {
                            if (trayItem.modelData.hasMenu) {
                                trayItem.isMenuOpen = !trayItem.isMenuOpen;
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
                
                // DBus Menu Opener
                QsMenuOpener {
                    id: menuOpener
                    menu: (trayItem.isMenuOpen && trayItem.modelData.hasMenu) ? trayItem.modelData.menu : null
                }
                
                // Dropdown Menu
                Rectangle {
                    id: menuPopup
                    visible: trayItem.isMenuOpen && menuOpener.children && menuOpener.children.values.length > 0
                    anchors.top: parent.bottom
                    anchors.topMargin: 8
                    anchors.right: parent.right
                    z: 99999
                    
                    implicitWidth: Math.max(140, menuCol.implicitWidth + 16)
                    implicitHeight: menuCol.implicitHeight + 12
                    radius: 6
                    color: Qt.rgba(pywal.color8.r, pywal.color8.g, pywal.color8.b, 0.98)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.18)
                    
                    ColumnLayout {
                        id: menuCol
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 2
                        
                        Repeater {
                            model: menuOpener.children ? menuOpener.children.values : []
                            
                            delegate: Item {
                                id: entryItem
                                required property var modelData
                                
                                readonly property bool isSep: modelData?.isSeparator ?? false
                                readonly property string rawText: modelData?.text ?? ""
                                readonly property string cleanText: rawText.replace(/&/g, "")
                                readonly property bool isEnabled: modelData?.enabled ?? true
                                
                                Layout.fillWidth: true
                                implicitHeight: isSep ? 5 : 24
                                
                                // Separator line
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: parent.width
                                    height: 1
                                    color: Qt.rgba(1, 1, 1, 0.15)
                                    visible: entryItem.isSep
                                }
                                
                                // Regular entry button
                                Rectangle {
                                    anchors.fill: parent
                                    radius: 4
                                    visible: !entryItem.isSep
                                    color: itemMouse.containsMouse && entryItem.isEnabled ? pywal.color1 : "transparent"
                                    
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 8
                                        anchors.rightMargin: 8
                                        spacing: 6
                                        
                                        // Icon if present
                                        IconImage {
                                            implicitWidth: 14
                                            implicitHeight: 14
                                            source: entryItem.modelData?.icon || ""
                                            visible: (entryItem.modelData?.icon ?? "") !== ""
                                        }
                                        
                                        // Text label
                                        Text {
                                            Layout.fillWidth: true
                                            text: entryItem.cleanText
                                            font.family: "JetBrainsMono Nerd Font Propo"
                                            font.pixelSize: 13
                                            color: itemMouse.containsMouse && entryItem.isEnabled ? pywal.color0 : (entryItem.isEnabled ? "white" : Qt.rgba(1, 1, 1, 0.4))
                                            elide: Text.ElideRight
                                        }
                                    }
                                    
                                    MouseArea {
                                        id: itemMouse
                                        anchors.fill: parent
                                        hoverEnabled: entryItem.isEnabled
                                        cursorShape: entryItem.isEnabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                        
                                        onClicked: {
                                            if (entryItem.isEnabled && entryItem.modelData) {
                                                entryItem.modelData.sendTriggered();
                                                trayItem.isMenuOpen = false;
                                                outsideDismissArea.visible = false;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
