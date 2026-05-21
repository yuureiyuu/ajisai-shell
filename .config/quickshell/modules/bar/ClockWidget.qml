import QtQuick
import QtQuick.Layouts
import "../../services"

ColumnLayout {
    id: root
    spacing: 1

    // timer
    Timer {
        id: timeSource
        interval: 1000
        running: true
        repeat: true
        property var currentDate: new Date()
        onTriggered: currentDate = new Date()
    }

    // time
    ColumnLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: -6

        Text {
            text: (timeSource.currentDate.getHours() % 12 || 12).toString().padStart(2, '0')
            font.pixelSize: 47
            color: Theme.text
            Layout.alignment: Qt.AlignHCenter
        }
        Text {
            text: Qt.formatDateTime(timeSource.currentDate, "mm")
            font.pixelSize: 47
            color: Theme.text
            Layout.alignment: Qt.AlignHCenter
        }
        Text {
            text: Qt.formatDateTime(timeSource.currentDate, "AP")
            font.pixelSize: 14
            color: Theme.subtext
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 5
        }
    }

    // date
    ColumnLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: 2
        Text {
            text: Qt.formatDateTime(timeSource.currentDate, "yyyy'年'")
            font.pixelSize: 12
            color: Theme.subtext
            Layout.alignment: Qt.AlignHCenter
        }
        Text {
            text: Qt.formatDateTime(timeSource.currentDate, "M'月'd'日'")
            font.pixelSize: 12
            color: Theme.subtext
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
