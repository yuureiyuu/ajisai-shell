pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../services"

Item {
    id: root

    readonly property date today: new Date()
    property int timerSeconds: 25 * 60
    property int initialTimerSeconds: 25 * 60
    property bool timerRunning: false

    function daysInMonth(dateValue) {
        return new Date(dateValue.getFullYear(), dateValue.getMonth() + 1, 0).getDate();
    }

    function firstDayOffset(dateValue) {
        const raw = new Date(dateValue.getFullYear(), dateValue.getMonth(), 1).getDay();
        return raw === 0 ? 6 : raw - 1;
    }

    function timerText() {
        const minutes = Math.floor(timerSeconds / 60).toString().padStart(2, "0");
        const seconds = Math.floor(timerSeconds % 60).toString().padStart(2, "0");
        return `${minutes}:${seconds}`;
    }

    Timer {
        interval: 1000
        repeat: true
        running: root.timerRunning
        onTriggered: {
            if (root.timerSeconds <= 1) {
                root.timerSeconds = 0;
                root.timerRunning = false;
            } else {
                root.timerSeconds--;
            }
        }
    }

    GridLayout {
        anchors.fill: parent
        columns: 2
        rowSpacing: 14
        columnSpacing: 14

        DashboardPanel {
            Layout.fillWidth: true
            Layout.preferredWidth: 430
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 14

                PanelHeader {
                    Layout.fillWidth: true
                    iconName: "calendar-days"
                    title: Qt.locale().toString(root.today, "MMMM yyyy")
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 7
                    rowSpacing: 8
                    columnSpacing: 8

                    Repeater {
                        model: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

                        Text {
                            required property string modelData

                            Layout.fillWidth: true
                            text: modelData
                            color: Theme.subtext
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    Repeater {
                        model: 42

                        Rectangle {
                            required property int index
                            readonly property int day: index - root.firstDayOffset(root.today) + 1
                            readonly property bool inMonth: day > 0 && day <= root.daysInMonth(root.today)
                            readonly property bool current: inMonth && day === root.today.getDate()

                            Layout.fillWidth: true
                            Layout.preferredHeight: 42
                            radius: 4
                            color: current ? Qt.alpha(Theme.accent, 0.24) : Qt.alpha(Theme.surface, inMonth ? 0.56 : 0.18)
                            border.width: current ? 1 : 0
                            border.color: Qt.alpha(Theme.accent, 0.52)

                            Text {
                                anchors.centerIn: parent
                                text: parent.inMonth ? String(parent.day) : ""
                                color: parent.current ? Theme.text : Theme.subtext
                                font.pixelSize: 13
                                font.weight: parent.current ? Font.DemiBold : Font.Normal
                            }
                        }
                    }
                }
            }
        }

        DashboardPanel {
            Layout.fillWidth: true
            Layout.preferredWidth: 430
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 14

                PanelHeader {
                    Layout.fillWidth: true
                    iconName: "list-todo"
                    title: "To-do"
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    radius: 4
                    color: Qt.alpha(Theme.surface, 0.86)
                    border.width: 1
                    border.color: Qt.alpha(Theme.border, 0.78)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 6
                        spacing: 8

                        TextField {
                            id: taskInput

                            Layout.fillWidth: true
                            color: Theme.text
                            placeholderText: "Add task"
                            placeholderTextColor: Theme.subtext
                            background: Item {}
                            selectByMouse: true
                            onAccepted: {
                                DashboardTodo.addTask(text);
                                text = "";
                            }
                        }

                        DashboardToolButton {
                            iconName: "plus"
                            onClicked: {
                                DashboardTodo.addTask(taskInput.text);
                                taskInput.text = "";
                            }
                        }
                    }
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 8
                    model: DashboardTodo.items

                    delegate: Rectangle {
                        required property var modelData
                        required property int index

                        width: ListView.view.width
                        height: 48
                        radius: 4
                        color: Qt.alpha(Theme.surface, modelData.done ? 0.38 : 0.72)
                        border.width: 1
                        border.color: Qt.alpha(Theme.border, 0.58)

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 6
                            spacing: 9

                            DashboardToolButton {
                                iconName: modelData.done ? "circle-check" : "circle-off"
                                onClicked: DashboardTodo.toggle(index)
                            }

                            Text {
                                Layout.fillWidth: true
                                text: modelData.content
                                color: modelData.done ? Theme.subtext : Theme.text
                                font.pixelSize: 13
                                elide: Text.ElideRight
                                font.strikeout: modelData.done
                            }

                            DashboardToolButton {
                                iconName: "trash-2"
                                danger: true
                                onClicked: DashboardTodo.remove(index)
                            }
                        }
                    }
                }
            }
        }

        DashboardPanel {
            Layout.fillWidth: true
            Layout.columnSpan: 2
            Layout.preferredHeight: 148

            RowLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 18

                PanelHeader {
                    Layout.preferredWidth: 150
                    iconName: "timer"
                    title: "Timer"
                }

                Text {
                    Layout.fillWidth: true
                    text: root.timerText()
                    color: Theme.text
                    font.pixelSize: 46
                    font.weight: Font.DemiBold
                    horizontalAlignment: Text.AlignHCenter
                }

                Rectangle {
                    Layout.preferredWidth: 108
                    Layout.preferredHeight: 44
                    radius: 4
                    color: Qt.alpha(Theme.surface, 0.86)
                    border.width: 1
                    border.color: Qt.alpha(Theme.border, 0.78)

                    TextField {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        text: String(Math.max(1, Math.round(root.initialTimerSeconds / 60)))
                        color: Theme.text
                        horizontalAlignment: Text.AlignHCenter
                        validator: IntValidator {
                            bottom: 1
                            top: 999
                        }
                        background: Item {}
                        onAccepted: {
                            root.initialTimerSeconds = Math.max(1, Number(text) || 25) * 60;
                            root.timerSeconds = root.initialTimerSeconds;
                            root.timerRunning = false;
                        }
                    }
                }

                DashboardToolButton {
                    Layout.preferredWidth: 46
                    Layout.preferredHeight: 46
                    iconName: root.timerRunning ? "pause" : "play"
                    primary: true
                    onClicked: root.timerRunning = !root.timerRunning
                }

                DashboardToolButton {
                    Layout.preferredWidth: 46
                    Layout.preferredHeight: 46
                    iconName: "timer-reset"
                    onClicked: {
                        root.timerRunning = false;
                        root.timerSeconds = root.initialTimerSeconds;
                    }
                }
            }
        }
    }
}
