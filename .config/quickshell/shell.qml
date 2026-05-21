import Quickshell
import "./services"
import "./modules/bar/"
import "./modules/session/"
import "./modules/launcher/"
import "./modules/lock/"
import "./modules/systemMonitor/"

ShellRoot {
    LockScreen {
        id: lockScreen

        onLockedChanged: {
            if (!locked)
                return;

            sessionWidget.visible = false;
            appLauncher.close();
            systemMonitor.close();
        }
    }

    Sidebar {
        visible: !sessionWidget.visible && !lockScreen.locked && !LockState.pendingLock
        onPowerClicked: sessionWidget.toggle()
    }

    AppLauncher {
        id: appLauncher
    }

    SessionWidget {
        id: sessionWidget
    }

    SystemMonitor {
        id: systemMonitor
    }
}
//Quickshell Types: "https://quickshell.org/docs/v0.2.1/types"
//QtQuick Types: "https://doc.qt.io/qt-6/qtquick-qmlmodule.html"
//quickshell shell example1: "https://github.com/caelestia-dots/shell"
//quickshell shell example2: "https://github.com/end-4/dots-hyprland/tree/main/dots/.config/quickshell/ii"
//AppLauncher { id: appLauncher }
