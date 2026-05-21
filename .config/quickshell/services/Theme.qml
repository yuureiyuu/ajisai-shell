pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string stateRoot: `${Quickshell.env("XDG_STATE_HOME") || `${Quickshell.env("HOME")}/.local/state`}/quickshell/theme`
    readonly property string paletteFilePath: `${stateRoot}/palette.json`
    readonly property string wallpaperFilePath: `${stateRoot}/current-wallpaper`
    readonly property string applyScriptPath: Quickshell.shellPath("scripts/theme/apply_wallpaper.sh")
    readonly property string extractScriptPath: Quickshell.shellPath("scripts/theme/extract_palette.py")
    readonly property string applyTargetsScriptPath: Quickshell.shellPath("scripts/theme/apply_targets.sh")

    property string currentWallpaper: ""
    property string baseHex: "#24273a"
    property string mantleHex: "#1e2030"
    property string surfaceHex: "#363a4f"
    property string surface2Hex: "#494d64"
    property string textHex: "#cad3f5"
    property string subtextHex: "#939ab7"
    property string accentHex: "#8aadf4"
    property string accent2Hex: "#c6a0f6"
    property string borderHex: "#494d64"
    property string swatch0: "#8aadf4"
    property string swatch1: "#c6a0f6"
    property string swatch2: "#cad3f5"
    property string swatch3: "#939ab7"
    property string swatch4: "#494d64"
    property string swatch5: "#363a4f"
    property string swatch6: "#24273a"
    property string swatch7: "#1e2030"
    property color base: root.baseHex
    property color mantle: root.mantleHex
    property color surface: root.surfaceHex
    property color surface2: root.surface2Hex
    property color text: root.textHex
    property color subtext: root.subtextHex
    property color accent: root.accentHex
    property color accent2: root.accent2Hex
    property color border: root.borderHex

    function applyPalette(payload) {
        if (!payload || !payload.length)
            return;

        try {
            const data = JSON.parse(payload);
            root.baseHex = data.base || root.baseHex;
            root.mantleHex = data.mantle || root.mantleHex;
            root.surfaceHex = data.surface || root.surfaceHex;
            root.surface2Hex = data.surface2 || root.surface2Hex;
            root.textHex = data.text || root.textHex;
            root.subtextHex = data.subtext || root.subtextHex;
            root.accentHex = data.accent || root.accentHex;
            root.accent2Hex = data.accent2 || root.accent2Hex;
            root.borderHex = data.border || root.borderHex;
            const colors = Array.isArray(data.colors) && data.colors.length >= 8 ? data.colors : [root.accentHex, root.accent2Hex, root.textHex, root.subtextHex, root.surface2Hex, root.surfaceHex, root.baseHex, root.mantleHex];
            root.swatch0 = colors[0];
            root.swatch1 = colors[1];
            root.swatch2 = colors[2];
            root.swatch3 = colors[3];
            root.swatch4 = colors[4];
            root.swatch5 = colors[5];
            root.swatch6 = colors[6];
            root.swatch7 = colors[7];
        } catch (error) {
            console.warn("Failed to parse palette payload", error);
        }
    }

    function applyWallpaper(path) {
        if (!path || !path.length)
            return;

        applyWallpaperProc.targetPath = path;
        applyWallpaperProc.command = [root.applyScriptPath, path];
        applyWallpaperProc.running = true;
    }

    function refreshPalette(path) {
        if (!path || !path.length)
            return;

        extractPaletteProc.command = ["python3", root.extractScriptPath, path, root.paletteFilePath];
        extractPaletteProc.running = true;
    }

    function applyTargets() {
        applyTargetsProc.command = [root.applyTargetsScriptPath];
        applyTargetsProc.running = true;
    }

    Process {
        id: applyWallpaperProc

        property string targetPath: ""
        stdout: StdioCollector {}
        stderr: StdioCollector {}

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0)
                return;

            root.currentWallpaper = targetPath;
            wallpaperFileView.reload();
            root.refreshPalette(targetPath);
        }
    }

    Process {
        id: extractPaletteProc

        stdout: StdioCollector {
            id: paletteCollector

            onStreamFinished: root.applyPalette(text)
        }

        stderr: StdioCollector {}

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                paletteFileView.reload();
                root.applyTargets();
            }
        }
    }

    Process {
        id: applyTargetsProc

        stdout: StdioCollector {}
        stderr: StdioCollector {}
    }

    FileView {
        id: paletteFileView

        path: root.paletteFilePath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.applyPalette(text())
    }

    FileView {
        id: wallpaperFileView

        path: root.wallpaperFilePath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            root.currentWallpaper = text().trim();
            if (root.currentWallpaper.length)
                root.refreshPalette(root.currentWallpaper);
        }
    }
}
