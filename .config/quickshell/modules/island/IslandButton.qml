import QtQuick
import "../../services"
import "../../components"

Item {
    id: root

    required property string iconName
    readonly property bool hovered: mouseArea.containsMouse
    property bool active: false
    signal clicked

    implicitWidth: 58
    implicitHeight: 46

    ThemedSvgIcon {
        anchors.centerIn: parent
        iconName: root.iconName
        iconSize: 26
        color: Theme.accent
        opacity: root.active || root.hovered ? 0.18 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 140
                easing.type: Easing.OutCubic
            }
        }
    }

    ThemedSvgIcon {
        anchors.centerIn: parent
        iconName: root.iconName
        iconSize: 26
        color: root.active || root.hovered ? Theme.iconActive : Theme.icon
        opacity: root.active || root.hovered ? 1.0 : 0.84
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: root.clicked()
    }
}
