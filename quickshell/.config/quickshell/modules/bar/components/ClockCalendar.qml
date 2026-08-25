import QtQuick 6.10
import QtQuick.Layouts 6.10
import "../../../services" as QsServices

Rectangle {
    id: root
    
    readonly property var pywal: QsServices.Pywal
    readonly property var time: QsServices.Time
    readonly property date currentDate: time.date
    
    readonly property int currentYear: currentDate.getFullYear()
    readonly property int currentMonth: currentDate.getMonth() // 0-11
    readonly property int currentDay: currentDate.getDate() // 1-31
    
    width: 220
    height: 200
    radius: 6
    color: Qt.rgba(pywal.color8.r, pywal.color8.g, pywal.color8.b, 0.95)
    border.width: 1
    border.color: Qt.rgba(1, 1, 1, 0.15)
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 6
        
        // Month Year Header
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: Qt.formatDate(root.currentDate, "MMMM yyyy")
            font.family: "JetBrainsMono Nerd Font Propo"
            font.pixelSize: 14
            font.bold: true
            color: "white"
        }
        
        // Days of week header
        RowLayout {
            Layout.fillWidth: true
            spacing: 2
            
            Repeater {
                model: ["Do", "Se", "Te", "Qa", "Qi", "Se", "Sa"]
                delegate: Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 11
                    font.bold: true
                    color: pywal.color1
                }
            }
        }
        
        // Days Grid
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 7
            rows: 6
            rowSpacing: 2
            columnSpacing: 2
            
            // Calculate first day of month (0 = Sun, 1 = Mon...)
            readonly property int firstDayOfWeek: new Date(root.currentYear, root.currentMonth, 1).getDay()
            readonly property int daysInMonth: new Date(root.currentYear, root.currentMonth + 1, 0).getDate()
            readonly property int prevMonthDays: new Date(root.currentYear, root.currentMonth, 0).getDate()
            
            Repeater {
                model: 42
                
                delegate: Rectangle {
                    id: dayCell
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 3
                    
                    readonly property int dayOffset: index - parent.firstDayOfWeek + 1
                    readonly property bool isCurrentMonth: dayOffset >= 1 && dayOffset <= parent.daysInMonth
                    readonly property bool isToday: isCurrentMonth && dayOffset === root.currentDay
                    readonly property int displayDay: {
                        if (dayOffset < 1) {
                            return parent.prevMonthDays + dayOffset;
                        } else if (dayOffset > parent.daysInMonth) {
                            return dayOffset - parent.daysInMonth;
                        }
                        return dayOffset;
                    }
                    
                    color: isToday ? "#75f1fa" : "transparent"
                    
                    Text {
                        anchors.centerIn: parent
                        text: dayCell.displayDay.toString()
                        font.family: "JetBrainsMono Nerd Font Propo"
                        font.pixelSize: 11
                        font.bold: dayCell.isToday
                        color: dayCell.isToday ? "#0a0a17" : (dayCell.isCurrentMonth ? "white" : Qt.rgba(1, 1, 1, 0.3))
                    }
                }
            }
        }
    }
}
