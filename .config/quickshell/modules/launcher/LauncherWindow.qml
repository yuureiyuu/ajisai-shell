import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Wayland
import "../../services"
import "../../components"

PanelWindow {
    id: root

    required property LauncherModel dataModel
    required property var launcher

    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true
    exclusiveZone: 0
    color: "transparent"
    WlrLayershell.namespace: "quickshell:applauncher"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    HyprlandFocusGrab {
        active: true
        windows: [root]
        onCleared: launcher.close()
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        MouseArea {
            anchors.fill: parent
            onClicked: launcher.close()
        }

        RectangularShadow {
            anchors.fill: launcherCard
            radius: launcherCard.radius
            blur: 16
            spread: 0
            offset: Qt.vector2d(0, 4)
            color: "#30000000"
            cached: true
        }

        Rectangle {
            id: launcherCard

            property real shownBottomMargin: 64
            width: Math.min(parent.width - 48, 640)
            height: dataModel && dataModel.wallpaperMode ? 236 : Math.min(parent.height * 0.72, 560)
            radius: 4
            color: Theme.base
            border.width: 1
            border.color: Theme.border
            clip: true

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: launcher.revealed ? shownBottomMargin : -height - 56

            Behavior on anchors.bottomMargin {
                NumberAnimation {
                    duration: 260
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 260
                }
            }

            opacity: launcher.closing ? 1 : (launcher.revealed ? 1 : 0.15)

            function activateItem(item) {
                if (!item)
                    return;

                if (item.kind === "wallpaper")
                    dataModel.applyWallpaper(item.filePath);
                else
                    dataModel.launchApp(item.entry);

                launcher.close();
            }

            Rectangle {
                anchors.fill: parent
                radius: launcherCard.radius
                color: Theme.base
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: root.dataModel && root.dataModel.wallpaperMode ? 12 : 14

                ListView {
                    id: resultsView

                    Layout.fillWidth: true
                    Layout.fillHeight: !root.dataModel.wallpaperMode
                    Layout.preferredHeight: root.dataModel.wallpaperMode ? 120 : -1
                    clip: true
                    spacing: 8
                    boundsBehavior: Flickable.StopAtBounds
                    keyNavigationEnabled: true
                    model: root.dataModel ? root.dataModel.filteredModel : []
                    orientation: root.dataModel && root.dataModel.wallpaperMode ? ListView.Horizontal : ListView.Vertical

                    delegate: Item {
                        id: itemRoot

                        required property var modelData
                        required property int index

                        width: root.dataModel && root.dataModel.wallpaperMode ? 120 : resultsView.width
                        height: root.dataModel && root.dataModel.wallpaperMode ? 110 : 68

                        RectangularShadow {
                            visible: root.dataModel && root.dataModel.wallpaperMode
                            anchors.fill: itemSurface
                            radius: itemSurface.radius
                            blur: itemRoot.ListView.isCurrentItem ? 10 : 7
                            spread: 0
                            offset: Qt.vector2d(0, itemRoot.ListView.isCurrentItem ? 2 : 1)
                            color: itemRoot.ListView.isCurrentItem ? Qt.alpha(Theme.accent, 0.14) : "#18000000"
                            cached: true
                        }

                        Rectangle {
                            id: itemSurface

                            anchors.fill: parent
                            anchors.leftMargin: root.dataModel && root.dataModel.wallpaperMode ? 4 : 0
                            anchors.rightMargin: root.dataModel && root.dataModel.wallpaperMode ? 4 : 0
                            anchors.topMargin: root.dataModel && root.dataModel.wallpaperMode ? 2 : 1
                            anchors.bottomMargin: root.dataModel && root.dataModel.wallpaperMode ? 4 : 3
                            radius: root.dataModel && root.dataModel.wallpaperMode ? 4 : 3
                            color: "transparent"
                            border.width: 0
                        }

                        RowLayout {
                            visible: !(root.dataModel && root.dataModel.wallpaperMode)
                            anchors.fill: itemSurface
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            spacing: 14

                            Rectangle {
                                Layout.preferredWidth: 2
                                Layout.preferredHeight: 34
                                radius: 1
                                color: Theme.accent
                                opacity: itemRoot.ListView.isCurrentItem ? 0.72 : 0

                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 120
                                    }
                                }
                            }

                            Item {
                                Layout.preferredWidth: 34
                                Layout.preferredHeight: 34

                                IconImage {
                                    anchors.centerIn: parent
                                    implicitSize: 30
                                    asynchronous: true
                                    source: modelData.kind === "wallpaper" ? modelData.fileUrl : Quickshell.iconPath(modelData.icon || "application-x-executable", "image-missing")
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.name
                                    color: Theme.text
                                    font.pixelSize: 16
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.description
                                    color: Theme.subtext
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                }
                            }
                        }

                        Column {
                            visible: root.dataModel && root.dataModel.wallpaperMode
                            anchors.fill: itemSurface
                            anchors.margins: 4
                            spacing: 6

                            Rectangle {
                                width: parent.width
                                height: 82
                                radius: 4
                                color: Qt.alpha(Theme.mantle, 0.22)
                                border.width: itemRoot.ListView.isCurrentItem ? 1 : 0
                                border.color: Theme.accent
                                clip: true

                                Image {
                                    anchors.fill: parent
                                    source: modelData.thumbnailUrl || ""
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    cache: true
                                    sourceSize.width: 320
                                    sourceSize.height: 180
                                    mipmap: true
                                }
                            }

                            Text {
                                width: parent.width
                                text: modelData.name.replace(/\.[^/.]+$/, "")
                                color: Theme.text
                                font.pixelSize: 12
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: resultsView.currentIndex = index
                            onClicked: launcherCard.activateItem(modelData)
                        }
                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56
                    Layout.bottomMargin: root.dataModel && root.dataModel.wallpaperMode ? 6 : 0
                    radius: 4
                    color: Theme.mantle
                    border.width: 1
                    border.color: Theme.border

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 10

                        LucideIcon {
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: 20
                            icon: Icons.search
                            iconSize: 18
                            color: Theme.iconMuted
                        }

                        TextField {
                            id: searchField

                            Layout.fillWidth: true
                            color: Theme.text
                            placeholderText: "Search apps or :wal"
                            placeholderTextColor: Theme.subtext
                            background: Item {}
                            selectByMouse: true
                            text: root.dataModel ? root.dataModel.query : ""

                            onTextChanged: {
                                if (!root.dataModel)
                                    return;

                                root.dataModel.query = text;
                                resultsView.currentIndex = root.dataModel.filteredModel.length > 0 ? 0 : -1;
                            }

                            onAccepted: {
                                if (root.dataModel && resultsView.currentIndex >= 0 && resultsView.currentIndex < root.dataModel.filteredModel.length)
                                    launcherCard.activateItem(root.dataModel.filteredModel[resultsView.currentIndex]);
                            }

                            Keys.onEscapePressed: launcher.close()
                            Keys.onDownPressed: {
                                if (root.dataModel && root.dataModel.filteredModel.length > 0)
                                    resultsView.currentIndex = Math.min(resultsView.currentIndex + 1, root.dataModel.filteredModel.length - 1);
                            }
                            Keys.onUpPressed: {
                                if (root.dataModel && root.dataModel.filteredModel.length > 0)
                                    resultsView.currentIndex = Math.max(resultsView.currentIndex - 1, 0);
                            }

                            Component.onCompleted: forceActiveFocus()
                        }

                        Rectangle {
                            visible: searchField.text.length > 0
                            width: 24
                            height: 24
                            radius: 0
                            color: clearMouseArea.containsMouse ? Theme.surface : "transparent"

                            LucideIcon {
                                anchors.centerIn: parent
                                icon: Icons.circleX
                                iconSize: 15
                                color: Theme.icon
                            }

                            MouseArea {
                                id: clearMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: searchField.clear()
                            }
                        }
                    }
                }
            }

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    launcher.close();
                    event.accepted = true;
                }
            }

            Connections {
                target: root.dataModel

                function onFilteredModelChanged() {
                    resultsView.currentIndex = root.dataModel && root.dataModel.filteredModel.length > 0 ? 0 : -1;
                }
            }

            Component.onCompleted: {
                if (root.dataModel) {
                    root.dataModel.query = "";
                    resultsView.currentIndex = root.dataModel.filteredModel.length > 0 ? 0 : -1;
                }
                searchField.forceActiveFocus();
            }
        }
    }
}
