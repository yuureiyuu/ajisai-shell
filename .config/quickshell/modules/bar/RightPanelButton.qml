import QtQuick
import "../../services"
import "../../components"

Item {
    id: root

    width: 35
    height: 35
    signal clicked

    readonly property bool hovered: mouseArea.containsMouse

    ThemedSvgIcon {
        anchors.centerIn: parent
        iconName: "smartphone"
        iconSize: 24
        color: Theme.accent
        opacity: root.hovered ? 0.18 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 140
                easing.type: Easing.OutCubic
            }
        }
    }

    ThemedSvgIcon {
        anchors.centerIn: parent
        iconName: "smartphone"
        iconSize: 24
        color: root.hovered ? Theme.iconActive : Theme.icon
        opacity: root.hovered ? 1.0 : 0.84
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
