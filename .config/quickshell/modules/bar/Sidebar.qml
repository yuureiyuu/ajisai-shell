import QtQuick
import QtQuick.Effects
import Quickshell
import "../../services"

PanelWindow {
    id: root
    signal powerClicked
    signal rightPanelClicked

    anchors {
        top: true
        bottom: true
        right: true
        left: false
    }
    implicitWidth: 69
    color: "transparent"

    RectangularShadow {
        anchors.fill: barSurface
        radius: 0
        blur: 14
        spread: 0
        offset: Qt.vector2d(-2, 0)
        color: "#2f000000"
        cached: true
    }

    Rectangle {
        id: barSurface

        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }
        width: 69
        color: Qt.alpha(Theme.mantle, 0.94)
        radius: 0
        border.width: 0

        Rectangle {
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
            }
            width: 1
            color: Qt.alpha(Theme.accent, 0.32)
        }

        Rectangle {
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
                leftMargin: 1
            }
            width: 1
            color: Qt.alpha(Theme.text, 0.08)
        }

        Rectangle {
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
                leftMargin: 2
            }
            width: 10
            gradient: Gradient {
                orientation: Gradient.Horizontal

                GradientStop {
                    position: 0
                    color: Qt.alpha(Theme.base, 0.2)
                }

                GradientStop {
                    position: 1
                    color: Qt.alpha(Theme.base, 0)
                }
            }
        }

        Rectangle {
            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
            }
            width: 1
            color: Qt.alpha(Theme.base, 0.48)
        }
    }

    // 1. CLOCK
    ClockWidget {
        anchors.top: parent.top
        anchors.horizontalCenter: barSurface.horizontalCenter
        anchors.topMargin: 7
    }

    // 2. WORKSPACE
    WorkspaceWidget {
        anchors.centerIn: barSurface
        width: 50
    }

    // 3. TRAY
    TrayWidget {
        id: trayWidget
        anchors.bottom: batteryWidget.top
        anchors.horizontalCenter: barSurface.horizontalCenter
        anchors.bottomMargin: batteryWidget.hovered ? 39 : 15

        Behavior on anchors.bottomMargin {
            NumberAnimation {
                duration: 190
                easing.type: Easing.OutCubic
            }
        }
    }

    // 4. BATTERY
    BatteryWidget {
        id: batteryWidget
        anchors.bottom: rightPanelButton.top
        anchors.horizontalCenter: barSurface.horizontalCenter
        anchors.bottomMargin: 15
    }

    // 5. RIGHT PANEL
    RightPanelButton {
        id: rightPanelButton
        anchors.bottom: powerWidget.top
        anchors.horizontalCenter: barSurface.horizontalCenter
        anchors.bottomMargin: 15
        onClicked: root.rightPanelClicked()
    }

    // 6. POWER
    PowerWidget {
        id: powerWidget
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: barSurface.horizontalCenter
        anchors.bottomMargin: 15
        onClicked: root.powerClicked()
    }
}
