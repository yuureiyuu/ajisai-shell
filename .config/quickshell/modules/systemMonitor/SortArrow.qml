pragma ComponentBehavior: Bound

import QtQuick
import "../../services"

Canvas {
    id: root

    property bool descending: true
    property color arrowColor: Theme.text

    implicitWidth: 8
    implicitHeight: 8
    antialiasing: true

    onPaint: {
        const ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height);
        ctx.fillStyle = root.arrowColor;
        ctx.beginPath();

        if (root.descending) {
            ctx.moveTo(width / 2, height - 1);
            ctx.lineTo(1, 2);
            ctx.lineTo(width - 1, 2);
        } else {
            ctx.moveTo(width / 2, 1);
            ctx.lineTo(1, height - 2);
            ctx.lineTo(width - 1, height - 2);
        }

        ctx.closePath();
        ctx.fill();
    }

    onDescendingChanged: requestPaint()
    onArrowColorChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    Component.onCompleted: requestPaint()
}
