pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string filePath: Quickshell.shellPath("generated/dashboard-todo.json")
    property var items: []

    function save() {
        todoFile.setText(JSON.stringify(root.items));
    }

    function addTask(text) {
        const content = String(text || "").trim();
        if (!content.length)
            return;

        root.items = root.items.concat([
            {
                "content": content,
                "done": false,
                "createdAt": Date.now()
            }
        ]);
        save();
    }

    function toggle(index) {
        if (index < 0 || index >= root.items.length)
            return;

        const next = root.items.slice(0);
        next[index] = Object.assign({}, next[index], {
            "done": !next[index].done
        });
        root.items = next;
        save();
    }

    function remove(index) {
        if (index < 0 || index >= root.items.length)
            return;

        const next = root.items.slice(0);
        next.splice(index, 1);
        root.items = next;
        save();
    }

    FileView {
        id: todoFile

        path: root.filePath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                const parsed = JSON.parse(text());
                root.items = Array.isArray(parsed) ? parsed : [];
            } catch (error) {
                root.items = [];
            }
        }
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound)
                root.save();
        }
    }
}
