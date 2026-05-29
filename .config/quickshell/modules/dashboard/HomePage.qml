pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import "../../components"
import "../../services"

Item {
    id: root

    required property string osName
    required property string wmName

    GridLayout {
        anchors.fill: parent
        columns: 2
        rowSpacing: 14
        columnSpacing: 14

        DashboardPanel {
            Layout.fillWidth: true
            Layout.preferredWidth: 420
            Layout.preferredHeight: 230

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 14

                PanelHeader {
                    Layout.fillWidth: true
                    iconName: "circle-user-round"
                    title: "System"
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    rowSpacing: 10
                    columnSpacing: 10

                    Repeater {
                        model: [
                            {
                                "icon": "circle-user",
                                "label": "User",
                                "value": SystemStats.username || "unknown"
                            },
                            {
                                "icon": "laptop",
                                "label": "OS",
                                "value": root.osName
                            },
                            {
                                "icon": "panels-top-left",
                                "label": "WM",
                                "value": root.wmName
                            },
                            {
                                "icon": "timer",
                                "label": "Uptime",
                                "value": SystemStats.uptimeText || "0m"
                            }
                        ]

                        delegate: Rectangle {
                            required property var modelData

                            Layout.fillWidth: true
                            Layout.preferredHeight: 72
                            radius: 4
                            color: Qt.alpha(Theme.surface, 0.78)
                            border.width: 1
                            border.color: Qt.alpha(Theme.border, 0.70)

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 10

                                ThemedSvgIcon {
                                    Layout.preferredWidth: 22
                                    Layout.preferredHeight: 22
                                    iconName: modelData.icon
                                    iconSize: 22
                                    color: Theme.iconActive
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.label
                                        color: Theme.subtext
                                        font.pixelSize: 11
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.value
                                        color: Theme.text
                                        font.pixelSize: 14
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        DashboardPanel {
            Layout.fillWidth: true
            Layout.preferredWidth: 420
            Layout.preferredHeight: 230
            clip: true

            AnimatedImage {
                anchors.fill: parent
                anchors.margins: 1
                source: Quickshell.shellPath("assets/kurumi.gif")
                fillMode: Image.PreserveAspectCrop
                playing: root.visible
                cache: false
                smooth: true
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.alpha(Theme.base, 0.06)
            }
        }

        DashboardPanel {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.columnSpan: 2
            clip: true

            Image {
                id: albumArtSource

                anchors.fill: parent
                source: NowPlaying.activePlayer?.trackArtUrl ?? ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: false
                visible: false
            }

            MultiEffect {
                anchors.fill: parent
                source: albumArtSource
                visible: albumArtSource.source.toString().length > 0
                blurEnabled: true
                blurMax: 48
                blur: 1
                saturation: 0.52
                brightness: -0.24
            }

            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop {
                        position: 0
                        color: Qt.alpha(Theme.mantle, 0.84)
                    }
                    GradientStop {
                        position: 1
                        color: Qt.alpha(Theme.base, 0.95)
                    }
                }
            }

            Rectangle {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }
                height: 2
                color: Qt.alpha(Theme.accent, 0.42)
            }

            Rectangle {
                id: visualizerTrack

                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    margins: 18
                }
                height: 5
                radius: 3
                clip: true
                color: Qt.alpha(Theme.surface, 0.62)

                Rectangle {
                    id: visualizerGlow

                    width: Math.max(visualizerTrack.width * 0.24, 110)
                    height: parent.height
                    radius: parent.radius
                    x: -width
                    opacity: NowPlaying.isPlaying ? 1 : 0.18
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop {
                            position: 0
                            color: Qt.alpha(Theme.accent, 0)
                        }
                        GradientStop {
                            position: 0.5
                            color: Qt.alpha(Theme.accent, 0.95)
                        }
                        GradientStop {
                            position: 1
                            color: Qt.alpha(Theme.accent2, 0)
                        }
                    }

                    SequentialAnimation on x {
                        loops: Animation.Infinite
                        running: NowPlaying.isPlaying
                        NumberAnimation {
                            from: -visualizerGlow.width
                            to: visualizerTrack.width
                            duration: 1450
                            easing.type: Easing.InOutSine
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 180
                        }
                    }
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 22
                anchors.bottomMargin: 36
                spacing: 20

                Rectangle {
                    Layout.preferredWidth: 126
                    Layout.preferredHeight: 126
                    radius: 7
                    color: Qt.alpha(Theme.surface, 0.72)
                    border.width: 1
                    border.color: Qt.alpha(Theme.accent, 0.34)
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: NowPlaying.activePlayer?.trackArtUrl ?? ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: false
                        visible: source.toString().length > 0
                    }

                    ThemedSvgIcon {
                        anchors.centerIn: parent
                        visible: !(NowPlaying.activePlayer?.trackArtUrl ?? "").length
                        iconName: NowPlaying.isPlaying ? "disc-album" : "music"
                        iconSize: 52
                        color: Theme.iconActive
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 10

                    PanelHeader {
                        Layout.fillWidth: true
                        iconName: "music-2"
                        title: "Music"
                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    Text {
                        Layout.fillWidth: true
                        text: NowPlaying.title.length ? NowPlaying.title : "Nothing is playing"
                        color: Theme.text
                        font.pixelSize: 26
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: NowPlaying.artist.length ? NowPlaying.artist : (NowPlaying.player.length ? NowPlaying.player : "MPRIS player")
                        color: Theme.subtext
                        font.pixelSize: 14
                        elide: Text.ElideRight
                    }

                    RowLayout {
                        Layout.topMargin: 8
                        spacing: 12

                        MediaButton {
                            iconName: "skip-back"
                            enabled: NowPlaying.activePlayer?.canGoPrevious ?? false
                            onClicked: NowPlaying.activePlayer?.previous()
                        }

                        MediaButton {
                            iconName: NowPlaying.isPlaying ? "pause" : "play"
                            enabled: (NowPlaying.activePlayer?.canPause ?? false) || (NowPlaying.activePlayer?.canPlay ?? false)
                            primary: true
                            onClicked: NowPlaying.activePlayer?.togglePlaying()
                        }

                        MediaButton {
                            iconName: "skip-forward"
                            enabled: NowPlaying.activePlayer?.canGoNext ?? false
                            onClicked: NowPlaying.activePlayer?.next()
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                }
            }
        }
    }
}
