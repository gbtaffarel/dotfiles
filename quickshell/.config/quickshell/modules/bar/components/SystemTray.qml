import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../../../services" as QsServices

Rectangle {
    id: root
    
    property var barWindow
    property var activeOpenItem: null
    
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
                width: 18
                height: 18
                Layout.preferredWidth: 18
                Layout.preferredHeight: 18
                
                onIsMenuOpenChanged: {
                    if (isMenuOpen) {
                        if (root.activeOpenItem && root.activeOpenItem !== trayItem) {
                            root.activeOpenItem.isMenuOpen = false;
                        }
                        root.activeOpenItem = trayItem;
                        if (menuOpener.menu && typeof menuOpener.menu.opened === "function") {
                            menuOpener.menu.opened();
                        }
                    } else {
                        if (root.activeOpenItem === trayItem) {
                            root.activeOpenItem = null;
                        }
                        if (menuOpener.menu && typeof menuOpener.menu.closed === "function") {
                            menuOpener.menu.closed();
                        }
                    }
                }
                
                IconImage {
                    anchors.fill: parent
                    source: trayItem.modelData.icon || ""
                }
                
                // DBus Menu Opener
                QsMenuOpener {
                    id: menuOpener
                    menu: trayItem.modelData.hasMenu ? trayItem.modelData.menu : null
                }
                
                // Hover timers for open and close
                Timer {
                    id: openTimer
                    interval: 160
                    onTriggered: {
                        if (trayItem.modelData.hasMenu) {
                            trayItem.isMenuOpen = true;
                        }
                    }
                }
                
                Timer {
                    id: closeTimer
                    interval: 400
                    onTriggered: {
                        if (!iconMouse.containsMouse && !popupHoverArea.containsMouse) {
                            trayItem.isMenuOpen = false;
                        }
                    }
                }
                
                MouseArea {
                    id: iconMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    hoverEnabled: true
                    
                    onEntered: {
                        closeTimer.stop();
                        if (trayItem.modelData.hasMenu) {
                            openTimer.start();
                        }
                    }
                    
                    onExited: {
                        openTimer.stop();
                        closeTimer.restart();
                    }
                    
                    onClicked: mouse => {
                        openTimer.stop();
                        closeTimer.stop();
                        
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
                
                // Custom Pywal Dropdown Menu Window anchored to the icon
                PopupWindow {
                    id: menuPopup
                    visible: trayItem.isMenuOpen && root.barWindow !== null && root.barWindow !== undefined && menuOpener.children && menuOpener.children.values.length > 0
                    
                    anchor.window: root.barWindow
                    anchor.item: trayItem
                    anchor.edges: Edges.Bottom
                    anchor.gravity: Edges.Bottom
                    anchor.adjustment: PopupAdjustment.All
                    anchor.margins.top: 4
                    
                    color: "transparent"
                    implicitWidth: menuContainer.implicitWidth
                    implicitHeight: menuContainer.implicitHeight
                    
                    onVisibleChanged: {
                        if (!visible) {
                            trayItem.isMenuOpen = false;
                        }
                    }
                    
                    Item {
                        id: menuContainer
                        implicitWidth: menuCard.implicitWidth
                        implicitHeight: menuCard.implicitHeight
                        
                        // Full-coverage hover tracker across the entire popup window
                        MouseArea {
                            id: popupHoverArea
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.NoButton
                            
                            onEntered: {
                                closeTimer.stop();
                            }
                            
                            onExited: {
                                closeTimer.restart();
                            }
                        }
                        
                        // Card background with Pywal theme
                        Rectangle {
                            id: menuCard
                            anchors.fill: parent
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
                                                
                                                onEntered: {
                                                    closeTimer.stop();
                                                }
                                                
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
}
