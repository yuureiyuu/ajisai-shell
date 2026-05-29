pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import "../../services"
import "../systemMonitor"

PanelWindow {
    id: root

    required property var dashboard
    property int activePage: 0
    property string osName: "Linux"
    readonly property string wmName: {
        if ((Quickshell.env("NIRI_SOCKET") || "").length)
            return "niri";
        if ((Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") || "").length)
            return "Hyprland";
        return Quickshell.env("XDG_CURRENT_DESKTOP") || Quickshell.env("DESKTOP_SESSION") || "Unknown";
    }

    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true
    exclusiveZone: 0
    color: "transparent"
    WlrLayershell.namespace: "quickshell:dashboard"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    SystemStatsConsumer {}

    FileView {
        path: "/etc/os-release"
        onLoaded: {
            const match = text().match(/^PRETTY_NAME="?([^"\n]+)"?/m);
            root.osName = match ? match[1] : "Linux";
        }
    }

    HyprlandFocusGrab {
        active: true
        windows: [root]
        onCleared: root.dashboard.close()
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        MouseArea {
            anchors.fill: parent
            onClicked: root.dashboard.close()
        }

        RectangularShadow {
            anchors.fill: card
            radius: card.radius
            blur: 26
            spread: 0
            offset: Qt.vector2d(0, 8)
            color: "#42000000"
            cached: true
        }

        Rectangle {
            id: card

            width: Math.min(parent.width - 36, 1020)
            height: Math.min(parent.height - 28, 620)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: root.dashboard.revealed ? 10 : -height - 24
            opacity: root.dashboard.closing ? 1 : (root.dashboard.revealed ? 1 : 0.2)
            radius: 6
            clip: true
            color: Theme.base
            border.width: 1
            border.color: Qt.alpha(Theme.accent, 0.30)

            Behavior on anchors.topMargin {
                NumberAnimation {
                    duration: 280
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 180
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.AllButtons
                onClicked: mouse => mouse.accepted = true
            }

            Rectangle {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }
                height: 88
                gradient: Gradient {
                    GradientStop {
                        position: 0
                        color: Qt.alpha(Theme.accent, 0.18)
                    }
                    GradientStop {
                        position: 1
                        color: Qt.alpha(Theme.accent, 0)
                    }
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16

                Rectangle {
                    Layout.preferredWidth: 92
                    Layout.fillHeight: true
                    radius: 5
                    color: Qt.alpha(Theme.mantle, 0.88)
                    border.width: 1
                    border.color: Qt.alpha(Theme.text, 0.08)

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Repeater {
                            model: [
                                {
                                    "icon": "home",
                                    "label": "Home"
                                },
                                {
                                    "icon": "calendar-days",
                                    "label": "Plan"
                                },
                                {
                                    "icon": "layout-dashboard",
                                    "label": "Soon"
                                }
                            ]

                            delegate: DashboardPageButton {
                                required property var modelData
                                required property int index

                                Layout.fillWidth: true
                                iconName: modelData.icon
                                label: modelData.label
                                active: root.activePage === index
                                onClicked: root.activePage = index
                            }
                        }

                        Item {
                            Layout.fillHeight: true
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    HomePage {
                        anchors.fill: parent
                        visible: root.activePage === 0
                        osName: root.osName
                        wmName: root.wmName
                    }

                    PlanPage {
                        anchors.fill: parent
                        visible: root.activePage === 1
                    }

                    SoonPage {
                        anchors.fill: parent
                        visible: root.activePage === 2
                    }
                }
            }

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    root.dashboard.close();
                    event.accepted = true;
                } else if (event.key === Qt.Key_1) {
                    root.activePage = 0;
                    event.accepted = true;
                } else if (event.key === Qt.Key_2) {
                    root.activePage = 1;
                    event.accepted = true;
                } else if (event.key === Qt.Key_3) {
                    root.activePage = 2;
                    event.accepted = true;
                }
            }

            Component.onCompleted: forceActiveFocus()
        }
    }
}
