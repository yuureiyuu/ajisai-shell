import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../../components"
import "../../services"

ColumnLayout {
    id: root
    width: 40
    spacing: 10

    property bool isOpen: false

    // Background applications list
    Item {
        id: trayListViewport

        property real animatedHeight: root.isOpen ? trayList.implicitHeight : 0

        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: 24
        Layout.preferredHeight: animatedHeight
        clip: true

        Behavior on animatedHeight {
            NumberAnimation {
                duration: 210
                easing.type: Easing.OutCubic
            }
        }

        ColumnLayout {
            id: trayList

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            spacing: 5
            opacity: root.isOpen ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 140
                }
            }

            Repeater {
                model: SystemTray.items

                delegate: IconImage {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 22
                    Layout.preferredHeight: 22
                    implicitSize: 22
                    source: modelData.icon
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
