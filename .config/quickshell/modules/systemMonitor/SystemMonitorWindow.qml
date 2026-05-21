pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "../../services"

PanelWindow {
    id: root

    required property var monitor
    property int activeTab: 0
    property string processQuery: ""
    property var filteredProcesses: []
    property var selectedProcess: null

    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true
    exclusiveZone: 0
    color: "transparent"
    WlrLayershell.namespace: "quickshell:system-monitor"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    function formatRate(bytes) {
        return `${SystemStats.formatBytes(bytes)}/s`;
    }

    function refreshFilteredProcesses() {
        const query = root.processQuery.trim().toLowerCase();
        const source = SystemStats.processes || [];
        if (!query.length) {
            root.filteredProcesses = source;
        } else {
            root.filteredProcesses = source.filter(process => {
                const haystack = `${process.pid} ${process.ppid} ${process.name} ${process.state} ${process.command}`.toLowerCase();
                return haystack.indexOf(query) >= 0;
            });
        }

        if (!root.selectedProcess && root.filteredProcesses.length > 0)
            root.selectedProcess = root.filteredProcesses[0];
        else if (root.selectedProcess && !root.filteredProcesses.some(process => process.pid === root.selectedProcess.pid))
            root.selectedProcess = root.filteredProcesses.length > 0 ? root.filteredProcesses[0] : null;
    }

    onProcessQueryChanged: refreshFilteredProcesses()

    SystemStatsConsumer {}

    Connections {
        target: SystemStats

        function onProcessesChanged() {
            root.refreshFilteredProcesses();
        }
    }

    HyprlandFocusGrab {
        active: true
        windows: [root]
        onCleared: monitor.close()
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, root.monitor.revealed ? 0.36 : 0)

        Behavior on color {
            ColorAnimation {
                duration: 180
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: monitor.close()
        }

        Rectangle {
            id: card

            width: Math.min(parent.width - 48, 1240)
            height: Math.min(parent.height - 48, 780)
            anchors.centerIn: parent
            anchors.verticalCenterOffset: root.monitor.revealed ? 0 : 22
            opacity: root.monitor.revealed ? 1 : 0
            radius: 8
            color: Theme.base
            border.width: 1
            border.color: Theme.border
            clip: true

            Behavior on opacity {
                NumberAnimation {
                    duration: 180
                }
            }

            Behavior on anchors.verticalCenterOffset {
                NumberAnimation {
                    duration: 240
                    easing.type: Easing.OutCubic
                }
            }

            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop {
                        position: 0
                        color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.86)
                    }
                    GradientStop {
                        position: 1
                        color: Theme.mantle
                    }
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 14

                Rectangle {
                    Layout.preferredWidth: 250
                    Layout.fillHeight: true
                    radius: 8
                    color: Qt.rgba(0, 0, 0, 0.18)
                    border.width: 1
                    border.color: Theme.border

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 14

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                Layout.fillWidth: true
                                text: "System Monitor"
                                color: Theme.text
                                font.pixelSize: 25
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                text: `${SystemStats.hostname} / ${SystemStats.username}`
                                color: Theme.subtext
                                font.pixelSize: 12
                                elide: Text.ElideRight
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 44
                                radius: 6
                                color: root.activeTab === 0 ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.18) : "transparent"
                                border.width: root.activeTab === 0 ? 1 : 0
                                border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.5)

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 12
                                    text: "Обзор железа"
                                    color: root.activeTab === 0 ? Theme.text : Theme.subtext
                                    font.pixelSize: 14
                                    font.weight: root.activeTab === 0 ? Font.DemiBold : Font.Normal
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: root.activeTab = 0
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 44
                                radius: 6
                                color: root.activeTab === 1 ? Qt.rgba(Theme.accent2.r, Theme.accent2.g, Theme.accent2.b, 0.18) : "transparent"
                                border.width: root.activeTab === 1 ? 1 : 0
                                border.color: Qt.rgba(Theme.accent2.r, Theme.accent2.g, Theme.accent2.b, 0.5)

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12

                                    Text {
                                        Layout.fillWidth: true
                                        text: "Процессы"
                                        color: root.activeTab === 1 ? Theme.text : Theme.subtext
                                        font.pixelSize: 14
                                        font.weight: root.activeTab === 1 ? Font.DemiBold : Font.Normal
                                    }

                                    Text {
                                        text: String(root.filteredProcesses.length)
                                        color: Theme.subtext
                                        font.pixelSize: 12
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        root.activeTab = 1;
                                        searchField.forceActiveFocus();
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: Theme.border
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Repeater {
                                model: [
                                    ["CPU", `${Math.round(SystemStats.cpuUsage)}%`, Theme.accent],
                                    ["RAM", `${Math.round(SystemStats.memoryUsage)}%`, Theme.accent2],
                                    ["GPU", SystemStats.gpuDisplayText, "#f9e2af"],
                                    ["NET", `${root.formatRate(SystemStats.networkRxRate)} down`, "#94e2d5"]
                                ]

                                Rectangle {
                                    required property var modelData

                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 58
                                    radius: 6
                                    color: Qt.rgba(0, 0, 0, 0.14)
                                    border.width: 1
                                    border.color: Qt.rgba(1, 1, 1, 0.06)

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 4

                                        RowLayout {
                                            Layout.fillWidth: true

                                            Text {
                                                text: modelData[0]
                                                color: Theme.subtext
                                                font.pixelSize: 11
                                                font.weight: Font.DemiBold
                                            }

                                            Item {
                                                Layout.fillWidth: true
                                            }

                                            Text {
                                                text: modelData[1]
                                                color: modelData[2]
                                                font.pixelSize: 12
                                                horizontalAlignment: Text.AlignRight
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 4
                                            radius: 2
                                            color: Qt.rgba(1, 1, 1, 0.08)

                                            Rectangle {
                                                width: parent.width * (modelData[0] === "CPU" ? SystemStats.cpuUsage : modelData[0] === "RAM" ? SystemStats.memoryUsage : modelData[0] === "GPU" ? SystemStats.gpuUsage : Math.min(100, SystemStats.networkRxRate / 1048576 * 12)) / 100
                                                height: parent.height
                                                radius: parent.radius
                                                color: modelData[2]

                                                Behavior on width {
                                                    NumberAnimation {
                                                        duration: 220
                                                        easing.type: Easing.OutCubic
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.fillHeight: true
                        }

                        Text {
                            Layout.fillWidth: true
                            text: SystemStats.lastKillResult.length ? SystemStats.lastKillResult : "Esc закрывает окно"
                            color: Theme.subtext
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Item {
                        anchors.fill: parent
                        visible: root.activeTab === 0

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 14

                            GridLayout {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 248
                                columns: 3
                                columnSpacing: 14
                                rowSpacing: 14

                                StatCard {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    title: "CPU"
                                    valueText: `${Math.round(SystemStats.cpuUsage)}%`
                                    detailText: `Uptime ${SystemStats.uptimeText} / ${SystemStats.temperatureText}`
                                    accent: Theme.accent
                                    history: SystemStats.cpuUsageHistory
                                }

                                StatCard {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    title: "Memory"
                                    valueText: `${Math.round(SystemStats.memoryUsage)}%`
                                    detailText: SystemStats.memoryDisplayText
                                    accent: Theme.accent2
                                    history: SystemStats.memoryUsageHistory
                                }

                                StatCard {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    title: "GPU"
                                    valueText: SystemStats.gpuDisplayText
                                    detailText: SystemStats.gpuUsageAvailable ? SystemStats.gpuName : SystemStats.gpuStatus
                                    accent: "#f9e2af"
                                    history: SystemStats.gpuUsageHistory
                                }
                            }

                            GridLayout {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 128
                                columns: 4
                                columnSpacing: 14
                                rowSpacing: 14

                                Repeater {
                                    model: [
                                        ["Disk", `${Math.round(SystemStats.diskUsage)}%`, SystemStats.diskText, "#a6e3a1", SystemStats.diskUsage],
                                        ["Swap", SystemStats.swapDisplayText, `${SystemStats.swapTotalGiB.toFixed(1)} GiB`, "#fab387", SystemStats.swapUsage],
                                        ["Battery", SystemStats.batteryDisplayText, SystemStats.batteryCharging ? "Charging" : "Discharging", "#f38ba8", SystemStats.batteryAvailable ? SystemStats.batteryLevel * 100 : 0],
                                        ["Processes", String(SystemStats.processCount), "sampled by ps", "#89b4fa", Math.min(100, SystemStats.processCount / 4)]
                                    ]

                                    Rectangle {
                                        required property var modelData

                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        radius: 8
                                        color: Theme.surface
                                        border.width: 1
                                        border.color: Theme.border

                                        ColumnLayout {
                                            anchors.fill: parent
                                            anchors.margins: 14
                                            spacing: 8

                                            Text {
                                                text: modelData[0]
                                                color: Theme.subtext
                                                font.pixelSize: 12
                                                font.weight: Font.DemiBold
                                            }

                                            Text {
                                                Layout.fillWidth: true
                                                text: modelData[1]
                                                color: modelData[3]
                                                font.pixelSize: 24
                                                font.weight: Font.Bold
                                                elide: Text.ElideRight
                                            }

                                            Text {
                                                Layout.fillWidth: true
                                                text: modelData[2]
                                                color: Theme.subtext
                                                font.pixelSize: 12
                                                elide: Text.ElideRight
                                            }

                                            Rectangle {
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 4
                                                radius: 2
                                                color: Qt.rgba(1, 1, 1, 0.08)

                                                Rectangle {
                                                    width: parent.width * Math.max(0, Math.min(100, modelData[4])) / 100
                                                    height: parent.height
                                                    radius: parent.radius
                                                    color: modelData[3]
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 14

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    radius: 8
                                    color: Theme.surface
                                    border.width: 1
                                    border.color: Theme.border

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 16
                                        spacing: 10

                                        RowLayout {
                                            Layout.fillWidth: true

                                            Text {
                                                text: "Network"
                                                color: Theme.text
                                                font.pixelSize: 20
                                                font.weight: Font.DemiBold
                                            }

                                            Item {
                                                Layout.fillWidth: true
                                            }

                                            Text {
                                                text: SystemStats.networkInterface
                                                color: Theme.subtext
                                                font.pixelSize: 12
                                            }
                                        }

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 12

                                            Text {
                                                Layout.fillWidth: true
                                                text: `Down ${root.formatRate(SystemStats.networkRxRate)}`
                                                color: "#94e2d5"
                                                font.pixelSize: 16
                                                font.weight: Font.DemiBold
                                            }

                                            Text {
                                                Layout.fillWidth: true
                                                text: `Up ${root.formatRate(SystemStats.networkTxRate)}`
                                                color: "#cba6f7"
                                                font.pixelSize: 16
                                                font.weight: Font.DemiBold
                                                horizontalAlignment: Text.AlignRight
                                            }
                                        }

                                        HistoryGraph {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            values: SystemStats.networkRxHistory
                                            lineColor: "#94e2d5"
                                            fillColor: Qt.rgba(0.58, 0.89, 0.84, 0.16)
                                        }

                                        HistoryGraph {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            values: SystemStats.networkTxHistory
                                            lineColor: "#cba6f7"
                                            fillColor: Qt.rgba(0.8, 0.65, 0.97, 0.14)
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.preferredWidth: 360
                                    Layout.fillHeight: true
                                    radius: 8
                                    color: Theme.surface
                                    border.width: 1
                                    border.color: Theme.border

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 16
                                        spacing: 10

                                        RowLayout {
                                            Layout.fillWidth: true

                                            Text {
                                                text: "Top CPU"
                                                color: Theme.text
                                                font.pixelSize: 20
                                                font.weight: Font.DemiBold
                                            }

                                            Item {
                                                Layout.fillWidth: true
                                            }

                                            Text {
                                                text: "ps"
                                                color: Theme.subtext
                                                font.pixelSize: 12
                                            }
                                        }

                                        Repeater {
                                            model: SystemStats.topProcesses

                                            Rectangle {
                                                required property var modelData

                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 34
                                                radius: 6
                                                color: Qt.rgba(0, 0, 0, 0.13)

                                                RowLayout {
                                                    anchors.fill: parent
                                                    anchors.leftMargin: 10
                                                    anchors.rightMargin: 10
                                                    spacing: 10

                                                    Text {
                                                        Layout.preferredWidth: 46
                                                        text: modelData.pid
                                                        color: Theme.subtext
                                                        font.pixelSize: 11
                                                    }

                                                    Text {
                                                        Layout.fillWidth: true
                                                        text: modelData.name
                                                        color: Theme.text
                                                        font.pixelSize: 12
                                                        elide: Text.ElideRight
                                                    }

                                                    Text {
                                                        Layout.preferredWidth: 54
                                                        text: `${modelData.cpu.toFixed(1)}%`
                                                        color: Theme.accent
                                                        font.pixelSize: 12
                                                        horizontalAlignment: Text.AlignRight
                                                    }
                                                }
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

                    Item {
                        anchors.fill: parent
                        visible: root.activeTab === 1

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 12

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 48
                                    radius: 8
                                    color: Theme.surface
                                    border.width: 1
                                    border.color: Theme.border

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 14
                                        anchors.rightMargin: 10
                                        spacing: 10

                                        Text {
                                            text: ">"
                                            color: Theme.subtext
                                            font.pixelSize: 16
                                        }

                                        TextField {
                                            id: searchField

                                            Layout.fillWidth: true
                                            color: Theme.text
                                            placeholderText: "Поиск по PID, имени, состоянию или команде"
                                            placeholderTextColor: Theme.subtext
                                            background: Item {}
                                            selectByMouse: true
                                            text: root.processQuery

                                            onTextChanged: root.processQuery = text
                                            Keys.onEscapePressed: monitor.close()
                                        }

                                        Rectangle {
                                            visible: searchField.text.length > 0
                                            Layout.preferredWidth: 26
                                            Layout.preferredHeight: 26
                                            radius: 6
                                            color: clearSearchArea.containsMouse ? Theme.surface2 : "transparent"

                                            Text {
                                                anchors.centerIn: parent
                                                text: "x"
                                                color: Theme.text
                                                font.pixelSize: 13
                                            }

                                            MouseArea {
                                                id: clearSearchArea
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                onClicked: searchField.clear()
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.preferredWidth: 168
                                    Layout.preferredHeight: 48
                                    radius: 8
                                    color: Theme.surface
                                    border.width: 1
                                    border.color: Theme.border

                                    Text {
                                        anchors.centerIn: parent
                                        text: `${root.filteredProcesses.length} / ${SystemStats.processCount}`
                                        color: Theme.text
                                        font.pixelSize: 14
                                        font.weight: Font.DemiBold
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 12

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    radius: 8
                                    color: Theme.surface
                                    border.width: 1
                                    border.color: Theme.border
                                    clip: true

                                    ColumnLayout {
                                        anchors.fill: parent
                                        spacing: 0

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 36
                                            color: Qt.rgba(0, 0, 0, 0.18)

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.leftMargin: 12
                                                anchors.rightMargin: 12
                                                spacing: 12

                                                Text { Layout.preferredWidth: 56; text: "PID"; color: Theme.subtext; font.pixelSize: 11; font.weight: Font.DemiBold }
                                                Text { Layout.fillWidth: true; text: "Process"; color: Theme.subtext; font.pixelSize: 11; font.weight: Font.DemiBold }
                                                Text { Layout.preferredWidth: 64; text: "CPU"; color: Theme.subtext; font.pixelSize: 11; font.weight: Font.DemiBold; horizontalAlignment: Text.AlignRight }
                                                Text { Layout.preferredWidth: 64; text: "RAM"; color: Theme.subtext; font.pixelSize: 11; font.weight: Font.DemiBold; horizontalAlignment: Text.AlignRight }
                                                Text { Layout.preferredWidth: 72; text: "RSS"; color: Theme.subtext; font.pixelSize: 11; font.weight: Font.DemiBold; horizontalAlignment: Text.AlignRight }
                                                Text { Layout.preferredWidth: 70; text: "GPU"; color: Theme.subtext; font.pixelSize: 11; font.weight: Font.DemiBold; horizontalAlignment: Text.AlignRight }
                                                Text { Layout.preferredWidth: 34; text: ""; color: Theme.subtext; font.pixelSize: 11 }
                                            }
                                        }

                                        ListView {
                                            id: processList

                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            clip: true
                                            spacing: 1
                                            boundsBehavior: Flickable.StopAtBounds
                                            model: root.filteredProcesses

                                            delegate: Rectangle {
                                                required property var modelData
                                                required property int index

                                                width: processList.width
                                                height: 42
                                                color: root.selectedProcess && root.selectedProcess.pid === modelData.pid ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : (index % 2 === 0 ? Qt.rgba(0, 0, 0, 0.08) : "transparent")

                                                MouseArea {
                                                    anchors.fill: parent
                                                    acceptedButtons: Qt.LeftButton
                                                    onClicked: root.selectedProcess = modelData
                                                }

                                                RowLayout {
                                                    anchors.fill: parent
                                                    anchors.leftMargin: 12
                                                    anchors.rightMargin: 12
                                                    spacing: 12

                                                    Text {
                                                        Layout.preferredWidth: 56
                                                        text: modelData.pid
                                                        color: Theme.subtext
                                                        font.pixelSize: 12
                                                    }

                                                    ColumnLayout {
                                                        Layout.fillWidth: true
                                                        spacing: 0

                                                        Text {
                                                            Layout.fillWidth: true
                                                            text: modelData.name
                                                            color: Theme.text
                                                            font.pixelSize: 13
                                                            font.weight: Font.DemiBold
                                                            elide: Text.ElideRight
                                                        }

                                                        Text {
                                                            Layout.fillWidth: true
                                                            text: modelData.command
                                                            color: Theme.subtext
                                                            font.pixelSize: 10
                                                            elide: Text.ElideRight
                                                        }
                                                    }

                                                    Text {
                                                        Layout.preferredWidth: 64
                                                        text: `${modelData.cpu.toFixed(1)}%`
                                                        color: Theme.accent
                                                        font.pixelSize: 12
                                                        horizontalAlignment: Text.AlignRight
                                                    }

                                                    Text {
                                                        Layout.preferredWidth: 64
                                                        text: `${modelData.memory.toFixed(1)}%`
                                                        color: Theme.accent2
                                                        font.pixelSize: 12
                                                        horizontalAlignment: Text.AlignRight
                                                    }

                                                    Text {
                                                        Layout.preferredWidth: 72
                                                        text: `${modelData.rssMiB.toFixed(modelData.rssMiB >= 100 ? 0 : 1)} MiB`
                                                        color: Theme.text
                                                        font.pixelSize: 12
                                                        horizontalAlignment: Text.AlignRight
                                                    }

                                                    Text {
                                                        Layout.preferredWidth: 70
                                                        text: modelData.gpuMemoryMiB > 0 ? `${modelData.gpuMemoryMiB} MiB` : "--"
                                                        color: modelData.gpuMemoryMiB > 0 ? "#f9e2af" : Theme.subtext
                                                        font.pixelSize: 12
                                                        horizontalAlignment: Text.AlignRight
                                                    }

                                                    Rectangle {
                                                        Layout.preferredWidth: 34
                                                        Layout.preferredHeight: 26
                                                        radius: 6
                                                        color: killMouse.containsMouse ? Qt.rgba(0.95, 0.42, 0.48, 0.24) : Qt.rgba(0.95, 0.42, 0.48, 0.1)
                                                        border.width: 1
                                                        border.color: Qt.rgba(0.95, 0.42, 0.48, 0.36)

                                                        Text {
                                                            anchors.centerIn: parent
                                                            text: "x"
                                                            color: "#f38ba8"
                                                            font.pixelSize: 13
                                                            font.weight: Font.Bold
                                                        }

                                                        MouseArea {
                                                            id: killMouse
                                                            anchors.fill: parent
                                                            hoverEnabled: true
                                                            onClicked: SystemStats.killProcess(modelData.pid, false)
                                                        }
                                                    }
                                                }
                                            }

                                            ScrollBar.vertical: ScrollBar {
                                                policy: ScrollBar.AsNeeded
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.preferredWidth: 300
                                    Layout.fillHeight: true
                                    radius: 8
                                    color: Theme.surface
                                    border.width: 1
                                    border.color: Theme.border

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 16
                                        spacing: 12

                                        Text {
                                            Layout.fillWidth: true
                                            text: root.selectedProcess ? root.selectedProcess.name : "No process"
                                            color: Theme.text
                                            font.pixelSize: 20
                                            font.weight: Font.DemiBold
                                            elide: Text.ElideRight
                                        }

                                        Repeater {
                                            model: root.selectedProcess ? [
                                                ["PID", root.selectedProcess.pid],
                                                ["PPID", root.selectedProcess.ppid],
                                                ["State", root.selectedProcess.state],
                                                ["Runtime", root.selectedProcess.runtime],
                                                ["CPU", `${root.selectedProcess.cpu.toFixed(1)}%`],
                                                ["RAM", `${root.selectedProcess.memory.toFixed(1)}%`],
                                                ["RSS", `${root.selectedProcess.rssMiB.toFixed(1)} MiB`],
                                                ["GPU memory", root.selectedProcess.gpuMemoryMiB > 0 ? `${root.selectedProcess.gpuMemoryMiB} MiB` : "Unavailable"]
                                            ] : []

                                            RowLayout {
                                                required property var modelData

                                                Layout.fillWidth: true

                                                Text {
                                                    text: modelData[0]
                                                    color: Theme.subtext
                                                    font.pixelSize: 12
                                                }

                                                Item {
                                                    Layout.fillWidth: true
                                                }

                                                Text {
                                                    Layout.maximumWidth: 160
                                                    text: modelData[1]
                                                    color: Theme.text
                                                    font.pixelSize: 12
                                                    horizontalAlignment: Text.AlignRight
                                                    elide: Text.ElideRight
                                                }
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 1
                                            color: Theme.border
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            text: root.selectedProcess ? root.selectedProcess.command : ""
                                            color: Theme.subtext
                                            font.pixelSize: 12
                                            wrapMode: Text.WrapAnywhere
                                            elide: Text.ElideRight
                                        }

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 8

                                            Rectangle {
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 38
                                                radius: 6
                                                color: termArea.containsMouse ? Qt.rgba(0.95, 0.42, 0.48, 0.22) : Qt.rgba(0.95, 0.42, 0.48, 0.12)
                                                border.width: 1
                                                border.color: Qt.rgba(0.95, 0.42, 0.48, 0.38)
                                                enabled: root.selectedProcess !== null
                                                opacity: enabled ? 1 : 0.45

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "TERM"
                                                    color: "#f38ba8"
                                                    font.pixelSize: 12
                                                    font.weight: Font.Bold
                                                }

                                                MouseArea {
                                                    id: termArea
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    onClicked: {
                                                        if (root.selectedProcess)
                                                            SystemStats.killProcess(root.selectedProcess.pid, false);
                                                    }
                                                }
                                            }

                                            Rectangle {
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 38
                                                radius: 6
                                                color: killForceArea.containsMouse ? Qt.rgba(0.95, 0.42, 0.48, 0.3) : Qt.rgba(0.95, 0.42, 0.48, 0.16)
                                                border.width: 1
                                                border.color: Qt.rgba(0.95, 0.42, 0.48, 0.5)
                                                enabled: root.selectedProcess !== null
                                                opacity: enabled ? 1 : 0.45

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "KILL"
                                                    color: "#f38ba8"
                                                    font.pixelSize: 12
                                                    font.weight: Font.Bold
                                                }

                                                MouseArea {
                                                    id: killForceArea
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    onClicked: {
                                                        if (root.selectedProcess)
                                                            SystemStats.killProcess(root.selectedProcess.pid, true);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    monitor.close();
                    event.accepted = true;
                } else if (event.key === Qt.Key_Tab) {
                    root.activeTab = root.activeTab === 0 ? 1 : 0;
                    event.accepted = true;
                    if (root.activeTab === 1)
                        searchField.forceActiveFocus();
                }
            }

            Component.onCompleted: {
                root.refreshFilteredProcesses();
                forceActiveFocus();
            }
        }
    }
}
