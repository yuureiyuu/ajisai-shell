import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import "../../components"
import "../../services"

ColumnLayout {
    id: root
    width: 40
    spacing: 10

    property bool isOpen: false

    // Background applications list
    ColumnLayout {
        id: trayList
        Layout.alignment: Qt.AlignHCenter
        visible: root.isOpen
        opacity: root.isOpen ? 1 : 0
        spacing: 5

        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
        }

        Repeater {
            model: SystemTray.items

            delegate: Image {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                source: modelData.icon
                fillMode: Image.PreserveAspectFit
                opacity: trayMouse.containsMouse ? 1.0 : 0.82

                MouseArea {
                    id: trayMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: modelData.activate()
                }
            }
        }
    }

    LucideIcon {
        id: toggleIcon
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: 24
        Layout.preferredHeight: 24
        iconSize: 23
        icon: root.isOpen ? Icons.eye : Icons.eyeOff
        color: toggleMouse.containsMouse ? Theme.iconActive : Theme.icon
        opacity: toggleMouse.containsMouse ? 1.0 : 0.82

        MouseArea {
            id: toggleMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.isOpen = !root.isOpen
        }
    }
}
