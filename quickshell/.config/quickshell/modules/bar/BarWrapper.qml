import Quickshell
import Quickshell.Wayland
import QtQuick 6.10

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: window
            
            property var modelData
            screen: modelData
            
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.namespace: "quickshell-bar"
            
            anchors {
                top: true
                left: true
                right: true
            }
            
            implicitHeight: 38
            color: "transparent"
            
            Loader {
                id: barLoader
                anchors.fill: parent
                source: "Bar.qml"
                
                onStatusChanged: {
                    if (status === Loader.Ready) {
                        item.screen = Qt.binding(() => modelData);
                        item.barWindow = Qt.binding(() => window);
                    }
                }
            }
        }
    }
}
