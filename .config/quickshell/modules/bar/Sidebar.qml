import QtQuick
import Quickshell
import "../../services"

PanelWindow {
    id: root
    signal powerClicked

    anchors {
        top: true
        bottom: true
        right: true
        left: false
    }
    implicitWidth: 65
    color: Theme.mantle

    // 1. CLOCK
    ClockWidget {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 7
    }

    // 2. TRAY
    TrayWidget {
        id: trayWidget
        anchors.bottom: batteryWidget.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 15
    }

    // 3. BATTERY
    BatteryWidget {
        id: batteryWidget
        anchors.bottom: powerWidget.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 15
    }

    // 4. POWER
    PowerWidget {
        id: powerWidget
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 15
        onClicked: root.powerClicked()
    }
}
