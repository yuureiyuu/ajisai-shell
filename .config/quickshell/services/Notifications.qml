pragma Singleton
pragma ComponentBehavior: Bound

import QtQml
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    property list<QtObject> list: []
    readonly property int unreadCount: list.length

    NotificationServer {
        id: server

        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        bodySupported: true
        imageSupported: true
        keepOnReload: false
        persistenceSupported: true

        onNotification: notification => {
            notification.tracked = true;

            const entry = notificationEntry.createObject(root, {
                notificationId: notification.id,
                appName: notification.appName || "Notification",
                summary: notification.summary || "",
                body: notification.body || "",
                time: new Date()
            });

            root.list = [entry, ...root.list].slice(0, 20);
        }
    }

    component NotificationEntry: QtObject {
        property int notificationId: 0
        property string appName: ""
        property string summary: ""
        property string body: ""
        property date time: new Date()
    }
}
