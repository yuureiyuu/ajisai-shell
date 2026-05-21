import QtQuick
import Quickshell

PanelWindow {
    id: root

    required property var launcher

    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true
    exclusiveZone: 0
    color: "transparent"

    anchors {
        left: true
        right: true
        bottom: true
    }

    implicitHeight: 18

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        Rectangle {
            id: handle
            width: 160
            height: 8
            radius: 0
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 4
            color: handleMouseArea.containsPress ? Theme.subtext : Theme.surface2
            opacity: handleMouseArea.containsMouse ? 0.95 : 0.72

            MouseArea {
                id: handleMouseArea
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                hoverEnabled: true
                onClicked: root.launcher.show()
            }
        }
    }
}
