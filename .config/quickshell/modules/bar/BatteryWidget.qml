import QtQuick
import "../../services"
import "../../utils"

Item {
    id: root

    width: 25
    height: 25
    clip: false
    readonly property bool hovered: batteryMouse.containsMouse

    readonly property int percent: {
        if (Config.useRealBattery && Battery.available)
            return Math.round(Battery.percentage * 100);
        if (!Config.useRealBattery)
            return 100;
        return 0;
    }
    readonly property int bars: percent >= 70 ? 3 : (percent >= 40 ? 2 : (percent > 10 ? 1 : 0))
    readonly property color outlineColor: percent <= 10 && Config.useRealBattery ? "#f38ba8" : Theme.icon
    readonly property color fillColor: Battery.isCharging ? Theme.iconActive : Theme.mixColor(Theme.accent, Theme.icon, 0.42)

    Item {
        id: batteryLayer

        width: 22
        height: 22
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: 1.5
        y: root.hovered ? -24 : 1
        opacity: root.hovered ? 0.9 : 1

        Behavior on y {
            NumberAnimation {
                duration: 190
                easing.type: Easing.OutCubic
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 120
            }
        }

        Item {
            anchors.centerIn: parent
            width: 25
            height: 17

            Rectangle {
                x: 0
                y: 2
                width: 21
                height: 13
                radius: 2.5
                color: "transparent"
                border.width: 1.8
                border.color: root.outlineColor
            }

            Rectangle {
                x: 22
                y: 6
                width: 3
                height: 5
                radius: 1
                color: root.outlineColor
            }

            Repeater {
                model: 3

                Rectangle {
                    required property int index

                    x: 3.5 + index * 5.7
                    y: 6
                    width: 3.4
                    height: 5
                    radius: 1
                    color: index < root.bars ? root.fillColor : "transparent"
                    opacity: index < root.bars ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 140
                        }
                    }
                }
            }
        }
    }

    Text {
        id: percentLabel

        width: parent.width
        height: parent.height
        y: root.hovered ? 0 : -24
        opacity: root.hovered ? 1 : 0
        text: root.percent
        color: Theme.icon
        font.pixelSize: 16
        font.weight: Font.DemiBold
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        Behavior on y {
            NumberAnimation {
                duration: 190
                easing.type: Easing.OutCubic
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 60
            }
        }
    }

    MouseArea {
        id: batteryMouse

        anchors.fill: parent
        anchors.margins: -5
        hoverEnabled: true
    }
}
