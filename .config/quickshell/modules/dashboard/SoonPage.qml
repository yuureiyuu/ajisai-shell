import QtQuick
import QtQuick.Layouts
import "../../components"
import "../../services"

Item {
    DashboardPanel {
        anchors.fill: parent

        ColumnLayout {
            anchors.centerIn: parent
            width: Math.min(parent.width - 80, 520)
            spacing: 18

            ThemedSvgIcon {
                Layout.alignment: Qt.AlignHCenter
                iconName: "layout-template"
                iconSize: 56
                color: Theme.iconActive
            }

            Text {
                Layout.fillWidth: true
                text: "Soon"
                color: Theme.text
                font.pixelSize: 42
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                Layout.fillWidth: true
                text: "Window layout controls for Hyprland and niriwm will live here."
                color: Theme.subtext
                font.pixelSize: 15
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
        }
    }
}
