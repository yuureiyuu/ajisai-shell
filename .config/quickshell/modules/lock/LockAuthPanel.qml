pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import "../../services"

Rectangle {
    id: root

    property real uiScale: 1
    property date currentDate: new Date()
    property string avatarPath: ""
    property int visiblePasswordLength: 0
    property bool passwordActive: false
    property int passwordBufferLength: 0
    property string statusText: ""

    signal submitRequested

    radius: 4
    color: Theme.surface
    border.width: 1
    border.color: Theme.border
    clip: true

    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: Math.max(0, parent.radius - 1)
        color: "transparent"
        border.width: 1
        border.color: Qt.alpha(Theme.text, 0.04)
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 1
        color: Qt.alpha(Theme.text, 0.08)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18 * root.uiScale
        spacing: 0

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 26 * root.uiScale
                width: Math.min(parent.width - 32, 360 * root.uiScale)
                spacing: 14 * root.uiScale

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 18 * root.uiScale

                    Text {
                        text: Qt.formatDateTime(root.currentDate, "hh:mm")
                        color: "white"
                        font.pixelSize: 74 * root.uiScale
                        font.weight: Font.DemiBold
                        font.letterSpacing: 0
                    }

                    ColumnLayout {
                        spacing: 2 * root.uiScale
                        Layout.alignment: Qt.AlignVCenter

                        RowLayout {
                            spacing: 8 * root.uiScale

                            Text {
                                text: Qt.formatDateTime(root.currentDate, "AP")
                                color: Theme.accent
                                font.pixelSize: 22 * root.uiScale
                                font.weight: Font.DemiBold
                            }

                            Text {
                                text: Qt.formatDateTime(root.currentDate, "dddd")
                                color: Qt.rgba(1, 1, 1, 0.82)
                                font.pixelSize: 20 * root.uiScale
                                font.weight: Font.Medium
                            }
                        }

                        Text {
                            text: Qt.formatDateTime(root.currentDate, "d MMMM yyyy")
                            color: Qt.rgba(1, 1, 1, 0.68)
                            font.pixelSize: 14 * root.uiScale
                            font.family: "monospace"
                        }
                    }
                }

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 12 * root.uiScale
                    width: 168 * root.uiScale
                    height: 168 * root.uiScale
                    radius: width / 2
                    color: Theme.base
                    border.width: 0
                    clip: true

                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        color: "transparent"
                        border.width: 1
                        border.color: Qt.alpha(Theme.text, 0.10)
                    }

                    Image {
                        id: avatarImage
                        anchors.fill: parent
                        source: root.avatarPath
                        sourceSize.width: 1024
                        sourceSize.height: 1024
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        smooth: true
                        mipmap: true
                        visible: status === Image.Ready
                        layer.enabled: true
                        layer.smooth: true
                        layer.textureSize: Qt.size(width * 4, height * 4)
                        layer.effect: MultiEffect {
                            maskEnabled: true
                            maskSource: avatarMask
                            maskThresholdMin: 0.5
                            maskSpreadAtMin: 1
                        }
                    }

                    Item {
                        id: avatarMask
                        anchors.fill: parent
                        layer.enabled: true
                        visible: false

                        Rectangle {
                            anchors.fill: parent
                            radius: width / 2
                            color: "white"
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: !avatarImage.visible
                        text: SystemStats.username.length ? SystemStats.username.charAt(0).toUpperCase() : "?"
                        color: "white"
                        font.pixelSize: 52 * root.uiScale
                        font.weight: Font.DemiBold
                    }
                }

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 4 * root.uiScale
                    Layout.fillWidth: true
                    radius: 4
                    color: Theme.base
                    border.width: 1
                    border.color: root.passwordActive ? Theme.accent : Theme.border
                    implicitHeight: 54 * root.uiScale

                    Item {
                        anchors.fill: parent
                        anchors.margins: 10 * root.uiScale

                        readonly property real actionButtonSize: 34 * root.uiScale

                        Item {
                            id: leftBalanceSpacer
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.actionButtonSize
                            height: parent.actionButtonSize
                        }

                        Text {
                            anchors.left: leftBalanceSpacer.right
                            anchors.right: submitButton.left
                            anchors.leftMargin: 10 * root.uiScale
                            anchors.rightMargin: 10 * root.uiScale
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.visiblePasswordLength > 0 ? Array(root.visiblePasswordLength + 1).join("• ") : "Enter your password"
                            color: Qt.rgba(1, 1, 1, 0.92)
                            font.pixelSize: 17 * root.uiScale
                            font.letterSpacing: root.visiblePasswordLength > 0 ? 1 : 0
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            maximumLineCount: 1
                            elide: Text.ElideRight
                        }

                        Rectangle {
                            id: submitButton
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.actionButtonSize
                            height: parent.actionButtonSize
                            radius: 4
                            color: root.passwordBufferLength ? Theme.accent : Theme.base

                            Item {
                                anchors.centerIn: parent
                                width: 10 * root.uiScale
                                height: 14 * root.uiScale

                                readonly property color arrowColor: root.passwordBufferLength ? Theme.mantle : Theme.text

                                Rectangle {
                                    width: 2 * root.uiScale
                                    height: 9 * root.uiScale
                                    radius: 1 * root.uiScale
                                    color: parent.arrowColor
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.verticalCenterOffset: -3 * root.uiScale
                                    rotation: -45
                                }

                                Rectangle {
                                    width: 2 * root.uiScale
                                    height: 9 * root.uiScale
                                    radius: 1 * root.uiScale
                                    color: parent.arrowColor
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.verticalCenterOffset: 3 * root.uiScale
                                    rotation: 45
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: root.submitRequested()
                            }
                        }
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: root.statusText.length ? root.statusText : "Press Enter to unlock"
                    color: root.statusText.length ? "#ffb4ab" : Qt.rgba(1, 1, 1, 0.58)
                    font.pixelSize: 12 * root.uiScale
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 16 * root.uiScale
                spacing: 12 * root.uiScale

                Repeater {
                    model: 8

                    Rectangle {
                        id: swatch

                        required property int index

                        width: 12 * root.uiScale
                        height: 12 * root.uiScale
                        rotation: 45
                        color: swatch.index === 0 ? Theme.swatch0 : swatch.index === 1 ? Theme.swatch1 : swatch.index === 2 ? Theme.swatch2 : swatch.index === 3 ? Theme.swatch3 : swatch.index === 4 ? Theme.swatch4 : swatch.index === 5 ? Theme.swatch5 : swatch.index === 6 ? Theme.swatch6 : Theme.swatch7
                        opacity: 0.68
                        border.width: 0
                        antialiasing: true
                    }
                }
            }
        }
    }
}
