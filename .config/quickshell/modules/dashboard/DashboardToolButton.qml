import QtQuick
import "../../components"
import "../../services"

Rectangle {
    id: root

    required property string iconName
    readonly property color dangerColor: "#ff6b6b"
    property bool primary: false
    property bool danger: false
    signal clicked

    implicitWidth: 34
    implicitHeight: 34
    radius: 4
    color: primary ? Qt.alpha(Theme.accent, 0.28) : Qt.alpha(Theme.surface2, 0.34)
    border.width: 1
    border.color: danger ? Qt.alpha(dangerColor, 0.34) : Qt.alpha(Theme.accent, primary ? 0.46 : 0.16)

    ThemedSvgIcon {
        anchors.centerIn: parent
        iconName: root.iconName
        iconSize: 17
        color: root.danger ? "#ff9a9a" : Theme.text
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
