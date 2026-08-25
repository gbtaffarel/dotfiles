import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../../../services" as QsServices

Rectangle {
    id: root
    
    property var barWindow
    
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
                
                property bool isMenuOpen: false
                
                implicitWidth: 18
                implicitHeight: 18
                
                IconImage {
                    anchors.fill: parent
                    source: trayItem.modelData.icon || ""
                }
                
                // DBus Menu Opener
                QsMenuOpener {
                    id: menuOpener
                    menu: trayItem.modelData.hasMenu ? trayItem.modelData.menu : null
                }
                
                onIsMenuOpenChanged: {
                    if (isMenuOpen && menuOpener.menu) {
                        if (typeof menuOpener.menu.opened === "function") {
                            menuOpener.menu.opened();
                        }
                    } else if (!isMenuOpen && menuOpener.menu) {
                        if (typeof menuOpener.menu.closed === "function") {
                            menuOpener.menu.closed();
                        }
                    }
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
                
                // Custom Pywal Dropdown Menu Window
                PopupWindow {
                    id: menuPopup
                    visible: trayItem.isMenuOpen && menuOpener.children && menuOpener.children.values.length > 0
                    
                    anchor.window: root.barWindow
                    anchor.item: trayItem
                    anchor.edges: Edges.Bottom
                    anchor.gravity: Edges.Bottom
                    anchor.margins.top: 8
                    
                    color: "transparent"
                    implicitWidth: menuCard.implicitWidth
                    implicitHeight: menuCard.implicitHeight
                    
                    onVisibleChanged: {
                        if (!visible) {
                            trayItem.isMenuOpen = false;
                        }
                    }
                    
                    // Card background with Pywal theme
                    Rectangle {
                        id: menuCard
                        implicitWidth: Math.max(200, menuCol.implicitWidth + 24)
                        implicitHeight: menuCol.implicitHeight + 16
                        radius: 8
                        color: Qt.rgba(pywal.background.r, pywal.background.g, pywal.background.b, 0.96)
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.15)
                        
                        ColumnLayout {
                            id: menuCol
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 3
                            
                            // App title header
                            RowLayout {
                                Layout.fillWidth: true
                                Layout.bottomMargin: 4
                                spacing: 6
                                
                                IconImage {
                                    implicitWidth: 14
                                    implicitHeight: 14
                                    source: trayItem.modelData.icon || ""
                                }
                                
                                Text {
                                    text: trayItem.modelData.title || trayItem.modelData.id || "Menu"
                                    font.family: "JetBrainsMono Nerd Font Propo"
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: pywal.color1
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                            }
                            
                            // Header divider
                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: Qt.rgba(1, 1, 1, 0.1)
                                Layout.bottomMargin: 2
                            }
                            
                            // Menu entries
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
                                    implicitHeight: isSep ? 7 : 26
                                    
                                    // Separator line
                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: parent.width
                                        height: 1
                                        color: Qt.rgba(1, 1, 1, 0.12)
                                        visible: entryItem.isSep
                                    }
                                    
                                    // Regular item button
                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 5
                                        visible: !entryItem.isSep
                                        color: itemMouse.containsMouse && entryItem.isEnabled ? pywal.color1 : "transparent"
                                        
                                        Behavior on color {
                                            ColorAnimation { duration: 120 }
                                        }
                                        
                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 8
                                            anchors.rightMargin: 8
                                            spacing: 8
                                            
                                            // Checkbox / radio indicator
                                            Text {
                                                visible: entryItem.modelData?.buttonType !== undefined && entryItem.modelData?.buttonType !== 0
                                                text: entryItem.modelData?.checkState === Qt.Checked ? "✓" : " "
                                                font.family: "JetBrainsMono Nerd Font Propo"
                                                font.pixelSize: 12
                                                font.bold: true
                                                color: itemMouse.containsMouse ? pywal.color0 : pywal.color1
                                                Layout.preferredWidth: 12
                                            }
                                            
                                            // Icon if available
                                            IconImage {
                                                implicitWidth: 14
                                                implicitHeight: 14
                                                source: entryItem.modelData?.icon || ""
                                                visible: (entryItem.modelData?.icon ?? "") !== ""
                                            }
                                            
                                            // Action text label
                                            Text {
                                                Layout.fillWidth: true
                                                text: entryItem.cleanText
                                                font.family: "JetBrainsMono Nerd Font Propo"
                                                font.pixelSize: 13
                                                font.bold: itemMouse.containsMouse
                                                color: itemMouse.containsMouse && entryItem.isEnabled ? pywal.color0 : (entryItem.isEnabled ? "white" : Qt.rgba(1, 1, 1, 0.35))
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
                                                    if (typeof entryItem.modelData.triggered === "function") {
                                                        entryItem.modelData.triggered();
                                                    } else if (typeof entryItem.modelData.sendTriggered === "function") {
                                                        entryItem.modelData.sendTriggered();
                                                    }
                                                    trayItem.isMenuOpen = false;
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
}
