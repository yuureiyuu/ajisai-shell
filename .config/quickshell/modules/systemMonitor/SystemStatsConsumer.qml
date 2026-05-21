pragma ComponentBehavior: Bound

import QtQml
import "../../services"

QtObject {
    id: root

    Component.onCompleted: SystemStats.retain()
    Component.onDestruction: SystemStats.release()
}
