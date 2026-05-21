pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../services"

Rectangle {
    id: root

    property real uiScale: 1

    Layout.fillWidth: true
    Layout.preferredHeight: 228 * root.uiScale
    radius: 0
    color: Theme.surface
    border.width: 1
    border.color: Theme.surface2
    clip: true

    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        color: "transparent"
        border.width: 1
        border.color: Qt.alpha(Theme.text, 0.07)
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 1
        color: Qt.alpha(Theme.accent, 0.18)
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: Qt.rgba(0, 0, 0, 0.24)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16 * root.uiScale
        spacing: 10 * root.uiScale

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Resources"
            color: "white"
            font.pixelSize: 24 * root.uiScale
            font.weight: Font.DemiBold
        }

        LockResourceMeter {
            uiScale: root.uiScale
            label: "CPU"
            value: SystemStats.cpuUsage
            valueText: `${Math.round(SystemStats.cpuUsage)}%`
            fillColor: Theme.accent
        }

        LockResourceMeter {
            uiScale: root.uiScale
            label: "Memory"
            value: SystemStats.memoryUsage
            valueText: `${Math.round(SystemStats.memoryUsage)}%`
            fillColor: Theme.accent2
        }

        LockResourceMeter {
            uiScale: root.uiScale
            label: "GPU"
            value: SystemStats.gpuUsage
            valueText: SystemStats.gpuDisplayText
            active: SystemStats.gpuDetected
            fillColor: Theme.swatch2
        }
    }
}
