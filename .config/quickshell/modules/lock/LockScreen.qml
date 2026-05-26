pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam
import "../../services"

Scope {
    id: root

    readonly property bool locked: LockState.locked
    readonly property string avatarPath: (Quickshell.env("HOME") || "") + "/.face"
    property date currentDate: new Date()
    readonly property real layoutScale: Math.max(0.72, Math.min(1.0, Math.min(screenWidth / 1440, screenHeight / 960)))
    readonly property real screenWidth: sessionLockSurface.width > 0 ? sessionLockSurface.width : 1366
    readonly property real screenHeight: sessionLockSurface.height > 0 ? sessionLockSurface.height : 768
    property string passwordBuffer: ""
    property string statusText: ""
    property bool passwordActive: passwordPam.active
    property int submittedPasswordLength: 0
    readonly property int visiblePasswordLength: Math.max(root.passwordBuffer.length, root.submittedPasswordLength)

    function lock() {
        root.currentDate = new Date();
        LockState.beginLock();
        delayedLockTimer.restart();
    }

    function unlock() {
        root.passwordBuffer = "";
        root.statusText = "";
        root.submittedPasswordLength = 0;
        LockState.unlock();
    }

    onLockedChanged: {
        root.passwordBuffer = "";
        root.statusText = "";
        root.submittedPasswordLength = 0;
        if (locked) {
            root.currentDate = new Date();
            NowPlaying.refresh();
        }
    }

    function submitPassword() {
        if (!root.passwordBuffer.length || passwordPam.active)
            return;

        root.submittedPasswordLength = root.passwordBuffer.length;
        root.statusText = "Checking password...";
        passwordPam.start();
    }

    function handleKey(event) {
        if (!root.locked)
            return;

        if (event.key === Qt.Key_Escape) {
            event.accepted = true;
            return;
        }

        if (passwordPam.active) {
            event.accepted = true;
            return;
        }

        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            root.submitPassword();
            event.accepted = true;
            return;
        }

        if (event.key === Qt.Key_Backspace) {
            root.passwordBuffer = root.passwordBuffer.slice(0, -1);
            root.submittedPasswordLength = 0;
            root.statusText = "";
            event.accepted = true;
            return;
        }

        if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_U) {
            root.passwordBuffer = "";
            root.submittedPasswordLength = 0;
            root.statusText = "";
            event.accepted = true;
            return;
        }

        if (event.text && event.text.length && event.text >= " ") {
            root.passwordBuffer += event.text;
            root.submittedPasswordLength = 0;
            root.statusText = "";
            event.accepted = true;
        }
    }

    PamContext {
        id: passwordPam

        config: "passwd"
        configDirectory: Quickshell.shellDir + "/assets/pam.d"

        onResponseRequiredChanged: {
            if (!responseRequired)
                return;

            respond(root.passwordBuffer);
            root.passwordBuffer = "";
        }

        onCompleted: result => {
            if (result === PamResult.Success) {
                root.unlock();
                return;
            }

            root.submittedPasswordLength = 0;
            if (result === PamResult.MaxTries)
                root.statusText = "Too many attempts";
            else if (message && message.length)
                root.statusText = message;
            else
                root.statusText = "Wrong password";
        }
    }

    GlobalShortcut {
        name: "lockScreen"
        description: "Locks the current session"
        onPressed: root.lock()
    }

    IpcHandler {
        target: "lock"

        function activate(): void {
            root.lock();
        }

        function deactivate(): void {
            root.unlock();
        }

        function isLocked(): bool {
            return LockState.locked;
        }
    }

    Timer {
        id: delayedLockTimer
        interval: 300
        repeat: false
        onTriggered: LockState.finishLock()
    }

    WlSessionLock {
        id: sessionLock
        locked: LockState.locked

        WlSessionLockSurface {
            id: sessionLockSurface
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                color: Theme.mantle
            }

            ScreencopyView {
                id: workspaceBackground
                anchors.fill: parent
                captureSource: sessionLockSurface.screen
                visible: wallpaperBackground.status !== Image.Ready
            }

            Image {
                id: wallpaperBackground
                anchors.fill: parent
                source: Theme.currentWallpaper
                sourceSize.width: sessionLockSurface.width
                sourceSize.height: sessionLockSurface.height
                fillMode: Image.PreserveAspectCrop
                asynchronous: false
                cache: true
                visible: status === Image.Ready
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0.03, 0.04, 0.06, 0.16)
            }

            Item {
                id: focusCatcher
                anchors.fill: parent
                focus: root.locked

                Keys.onPressed: event => root.handleKey(event)

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.ArrowCursor
                    onClicked: focusCatcher.forceActiveFocus()
                }

                Rectangle {
                    id: frame
                    anchors.centerIn: parent
                    width: Math.min(parent.width - 80, 1080 * root.layoutScale)
                    height: Math.min(parent.height - 80, 660 * root.layoutScale)
                    radius: 4
                    color: Theme.base
                    border.width: 1
                    border.color: Theme.border
                    clip: true

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 1
                        radius: Math.max(0, parent.radius - 1)
                        color: "transparent"
                        border.width: 1
                        border.color: Qt.alpha(Theme.text, 0.04)
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 16 * root.layoutScale
                        spacing: 16 * root.layoutScale

                        LockLeftColumn {
                            uiScale: root.layoutScale
                            Layout.preferredWidth: 236 * root.layoutScale
                            Layout.fillHeight: true
                        }

                        LockAuthPanel {
                            uiScale: root.layoutScale
                            currentDate: root.currentDate
                            avatarPath: root.avatarPath
                            visiblePasswordLength: root.visiblePasswordLength
                            passwordActive: root.passwordActive
                            passwordBufferLength: root.passwordBuffer.length
                            statusText: root.statusText
                            onSubmitRequested: {
                                focusCatcher.forceActiveFocus();
                                root.submitPassword();
                            }

                            Layout.preferredWidth: 520 * root.layoutScale
                            Layout.fillHeight: true
                        }

                        LockRightColumn {
                            uiScale: root.layoutScale
                            Layout.preferredWidth: 260 * root.layoutScale
                            Layout.fillHeight: true
                        }
                    }
                }

                Timer {
                    id: clockTimer
                    interval: 1000
                    running: root.locked
                    repeat: true
                    triggeredOnStart: true
                    onTriggered: root.currentDate = new Date()
                }

                Component.onCompleted: focusCatcher.forceActiveFocus()
            }
        }
    }
}
