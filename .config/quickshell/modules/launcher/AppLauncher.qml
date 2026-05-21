import QtQuick
import Quickshell
import Quickshell.Hyprland

Scope {
    id: root

    property bool open: false
    property bool closing: false
    property bool revealed: false
    readonly property bool visibleState: open || closing

    function toggle() {
        if (open)
            close();
        else
            show();
    }

    function show() {
        closing = false;
        open = true;
        revealed = false;
        revealTimer.restart();
    }

    function close() {
        if (!open && !closing)
            return;

        revealed = false;
        open = false;
        closing = true;
        closeTimer.restart();
    }

    LauncherModel {
        id: launcherData
    }

    LauncherHotZone {
        launcher: root
    }

    Loader {
        active: root.visibleState
        sourceComponent: LauncherWindow {
            dataModel: launcherData
            launcher: root
        }
    }

    Timer {
        id: revealTimer
        interval: 1
        onTriggered: root.revealed = true
    }

    Timer {
        id: closeTimer
        interval: 220
        onTriggered: root.closing = false
    }

    GlobalShortcut {
        name: "applauncherToggle"
        description: "Toggle app launcher"
        onPressed: root.toggle()
    }
}
