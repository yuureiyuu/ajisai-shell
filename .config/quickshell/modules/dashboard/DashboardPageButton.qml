import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import "../../components"
import "../../services"

Rectangle {
    id: root

    required property string iconName
    required property string label
    property bool active: false
    signal clicked

    Layout.preferredHeight: 70
    radius: 5
    color: active ? Qt.alpha(Theme.accent, 0.18) : "transparent"
    border.width: active ? 1 : 0
    border.color: Qt.alpha(Theme.accent, 0.44)

    RectangularShadow {
        anchors.fill: parent
        visible: root.active
        radius: parent.radius
        blur: 18
        spread: 0
        offset: Qt.vector2d(0, 0)
        color: Qt.alpha(Theme.accent, 0.18)
        cached: true
    }

    Column {
        anchors.centerIn: parent
        spacing: 5

        ThemedSvgIcon {
            anchors.horizontalCenter: parent.horizontalCenter
            iconName: root.iconName
            iconSize: 24
            color: root.active ? Theme.text : Theme.iconMuted
        }

        Text {
            width: root.width - 12
            text: root.label
            color: root.active ? Theme.text : Theme.subtext
            font.pixelSize: 11
            font.weight: root.active ? Font.DemiBold : Font.Normal
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: root.clicked()
    }
}
