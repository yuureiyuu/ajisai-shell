import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../services"

PanelWindow {
    id: root

    // Cover the entire screen
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    color: Theme.mantle
    visible: false

    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: Theme.mantle
        focus: root.visible

        Keys.onEscapePressed: root.visible = false

        MouseArea {
            anchors.fill: parent
            onClicked: root.visible = false
        }
    }

    Item {
        anchors.centerIn: parent
        width: 380
        height: 350

        Grid {
            id: buttonGrid
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            columns: 3
            spacing: 20

            SessionButton {
                id: btnReboot
                text: "Reboot"
                iconSource: "../../assets/reboot.svg"
                KeyNavigation.right: btnPowerOff
                KeyNavigation.down: btnSleep
                onClicked: {
                    root.visible = false;
                    SessionActions.reboot();
                }
                onHoverEntered: currentAction.text = text
                onHoverExited: if (!btnReboot.activeFocus)
                    currentAction.text = ""
                onActiveFocusChanged: if (activeFocus)
                    currentAction.text = text
                focus: true
            }

            SessionButton {
                id: btnPowerOff
                text: "PowerOff"
                iconSource: "../../assets/poweroff.svg"
                KeyNavigation.left: btnReboot
                KeyNavigation.right: btnLogout
                KeyNavigation.down: btnGif
                onClicked: {
                    root.visible = false;
                    SessionActions.poweroff();
                }
                onHoverEntered: currentAction.text = text
                onHoverExited: if (!btnPowerOff.activeFocus)
                    currentAction.text = ""
                onActiveFocusChanged: if (activeFocus)
                    currentAction.text = text
            }

            SessionButton {
                id: btnLogout
                text: "Logout"
                iconSource: "../../assets/logout.svg"
                KeyNavigation.left: btnPowerOff
                KeyNavigation.down: btnLock
                onClicked: {
                    root.visible = false;
                    SessionActions.logout();
                }
                onHoverEntered: currentAction.text = text
                onHoverExited: if (!btnLogout.activeFocus)
                    currentAction.text = ""
                onActiveFocusChanged: if (activeFocus)
                    currentAction.text = text
            }

            SessionButton {
                id: btnSleep
                text: "SleepMode"
                iconSource: "../../assets/sleepmode.svg"
                KeyNavigation.up: btnReboot
                KeyNavigation.right: btnGif
                onClicked: {
                    root.visible = false;
                    SessionActions.suspend();
                }
                onHoverEntered: currentAction.text = text
                onHoverExited: if (!btnSleep.activeFocus)
                    currentAction.text = ""
                onActiveFocusChanged: if (activeFocus)
                    currentAction.text = text
            }

            SessionButton {
                id: btnGif
                text: "i see you"
                isGif: true
                iconSource: "../../assets/ougi-oshino.png"
                KeyNavigation.up: btnPowerOff
                KeyNavigation.left: btnSleep
                KeyNavigation.right: btnLock
                onClicked: {
                    console.log("Ougi sees you.");
                    root.visible = false;
                }
                onHoverEntered: currentAction.text = text
                onHoverExited: if (!btnGif.activeFocus)
                    currentAction.text = ""
                onActiveFocusChanged: if (activeFocus)
                    currentAction.text = text
            }

            SessionButton {
                id: btnLock
                text: "ScreenLock"
                iconSource: "../../assets/lockscreen.svg"
                KeyNavigation.up: btnLogout
                KeyNavigation.left: btnGif
                onClicked: {
                    root.visible = false;
                    SessionActions.lock();
                }
                onHoverEntered: currentAction.text = text
                onHoverExited: if (!btnLock.activeFocus)
                    currentAction.text = ""
                onActiveFocusChanged: if (activeFocus)
                    currentAction.text = text
            }
        }

        Text {
            id: currentAction
            anchors.top: buttonGrid.bottom
            anchors.topMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter
            text: " "
            color: Theme.text
            font.pixelSize: 22
            font.weight: Font.Medium
        }
    }

    onVisibleChanged: {
        if (visible) {
            btnReboot.forceActiveFocus();
        }
    }

    function toggle() {
        visible = !visible;
    }
}
