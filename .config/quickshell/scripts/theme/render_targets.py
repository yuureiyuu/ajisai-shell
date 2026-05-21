#!/usr/bin/env python3

from __future__ import annotations

import json
import os
from pathlib import Path


HOME = Path.home()
CONFIG_HOME = Path(os.environ.get("XDG_CONFIG_HOME", HOME / ".config"))
CACHE_HOME = Path(os.environ.get("XDG_CACHE_HOME", HOME / ".cache"))
STATE_HOME = Path(os.environ.get("XDG_STATE_HOME", HOME / ".local/state"))
DATA_HOME = Path(os.environ.get("XDG_DATA_HOME", HOME / ".local/share"))


def hex_to_rgb_triplet(value: str) -> str:
    value = value.lstrip("#")
    return ",".join(str(int(value[i : i + 2], 16)) for i in (0, 2, 4))


def hex_to_rgb(value: str) -> tuple[int, int, int]:
    value = value.lstrip("#")
    return tuple(int(value[i : i + 2], 16) for i in (0, 2, 4))


def rgb_to_hex(value: tuple[int, int, int]) -> str:
    return "#{:02x}{:02x}{:02x}".format(*value)


def mix_hex(a: str, b: str, ratio: float) -> str:
    a_rgb = hex_to_rgb(a)
    b_rgb = hex_to_rgb(b)
    mixed = tuple(
        max(0, min(255, round((1 - ratio) * left + ratio * right)))
        for left, right in zip(a_rgb, b_rgb, strict=True)
    )
    return rgb_to_hex(mixed)


def terminal_palette(palette: dict[str, str]) -> dict[str, str]:
    terminal_background = mix_hex(palette["mantle"], palette["base"], 0.18)
    terminal_foreground = mix_hex(palette["text"], palette["accent"], 0.03)
    terminal_black = mix_hex(palette["mantle"], terminal_background, 0.10)
    terminal_bright_black = mix_hex(palette["surface"], palette["accent"], 0.04)

    # Build all ANSI accents from the extracted palette so they fully track wallpaper changes.
    # We mix with text color slightly to ensure they are visible on dark backgrounds.
    terminal_red = mix_hex(palette["accent"], palette["accent2"], 0.42)
    terminal_green = mix_hex(palette["accent2"], palette["text"], 0.35)
    terminal_yellow = mix_hex(palette["accent"], palette["text"], 0.35)
    terminal_blue = mix_hex(palette["accent"], palette["text"], 0.45)
    terminal_magenta = mix_hex(palette["accent2"], palette["accent"], 0.22)
    terminal_cyan = mix_hex(palette["accent2"], palette["text"], 0.55)
    terminal_selection_background = mix_hex(terminal_background, palette["accent"], 0.25)

    return {
        "foreground": terminal_foreground,
        "background": terminal_background,
        "regular0": terminal_black,
        "regular1": terminal_red,
        "regular2": terminal_green,
        "regular3": terminal_yellow,
        "regular4": terminal_blue,
        "regular5": terminal_magenta,
        "regular6": terminal_cyan,
        "regular7": terminal_foreground,
        "bright0": terminal_bright_black,
        "bright1": mix_hex(terminal_red, palette["text"], 0.35),
        "bright2": mix_hex(terminal_green, palette["text"], 0.35),
        "bright3": mix_hex(terminal_yellow, palette["text"], 0.35),
        "bright4": mix_hex(terminal_blue, palette["text"], 0.45),
        "bright5": mix_hex(terminal_magenta, palette["text"], 0.45),
        "bright6": mix_hex(terminal_cyan, palette["text"], 0.45),
        "bright7": palette["text"],
        "selection_foreground": terminal_foreground,
        "selection_background": terminal_selection_background,
        "cursor": terminal_foreground,
    }


def write_file(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def current_wallpaper_path() -> str:
    wallpaper_file = STATE_HOME / "quickshell/theme/current-wallpaper"
    if not wallpaper_file.exists():
        return ""
    return wallpaper_file.read_text(encoding="utf-8").strip()


def render_gtk_colors(palette: dict[str, str]) -> str:
    return f"""@define-color theme_bg_color {palette["base"]};
@define-color theme_fg_color {palette["text"]};
@define-color theme_base_color {palette["mantle"]};
@define-color theme_selected_bg_color {palette["accent"]};
@define-color theme_selected_fg_color {palette["text"]};
@define-color theme_unfocused_fg_color {palette["subtext"]};
@define-color theme_unfocused_bg_color {palette["surface"]};
@define-color borders {palette["border"]};
@define-color window_bg_color {palette["base"]};
@define-color window_fg_color {palette["text"]};
@define-color view_bg_color {palette["mantle"]};
@define-color view_fg_color {palette["text"]};
@define-color headerbar_bg_color {palette["surface"]};
@define-color headerbar_fg_color {palette["text"]};
@define-color accent_color {palette["accent"]};
@define-color accent_bg_color {palette["accent"]};
@define-color accent_fg_color {palette["text"]};
@define-color card_bg_color {palette["surface"]};
@define-color card_fg_color {palette["text"]};
@define-color popover_bg_color {palette["surface"]};
@define-color popover_fg_color {palette["text"]};
"""


def render_kde_colors(palette: dict[str, str]) -> str:
    base = hex_to_rgb_triplet(palette["base"])
    mantle = hex_to_rgb_triplet(palette["mantle"])
    surface = hex_to_rgb_triplet(palette["surface"])
    border = hex_to_rgb_triplet(palette["border"])
    text = hex_to_rgb_triplet(palette["text"])
    subtext = hex_to_rgb_triplet(palette["subtext"])
    accent = hex_to_rgb_triplet(palette["accent"])
    accent2 = hex_to_rgb_triplet(palette["accent2"])

    term = terminal_palette(palette)
    red = hex_to_rgb_triplet(term["regular1"])
    yellow = hex_to_rgb_triplet(term["regular3"])
    green = hex_to_rgb_triplet(term["regular2"])

    return f"""[General]
ColorScheme=QuickshellDiploma
Name=QuickshellDiploma
shadeSortColumn=true

[Colors:Button]
BackgroundAlternate={surface}
BackgroundNormal={surface}
DecorationFocus={accent}
DecorationHover={accent2}
ForegroundActive={accent}
ForegroundInactive={subtext}
ForegroundLink={accent2}
ForegroundNegative={red}
ForegroundNeutral={yellow}
ForegroundNormal={text}
ForegroundPositive={green}
ForegroundVisited={accent2}

[Colors:Selection]
BackgroundAlternate={accent}
BackgroundNormal={accent}
DecorationFocus={accent}
DecorationHover={accent2}
ForegroundActive={text}
ForegroundInactive={text}
ForegroundLink={text}
ForegroundNegative={text}
ForegroundNeutral={text}
ForegroundNormal={text}
ForegroundPositive={text}
ForegroundVisited={text}

[Colors:Tooltip]
BackgroundAlternate={surface}
BackgroundNormal={surface}
DecorationFocus={accent}
DecorationHover={accent2}
ForegroundActive={accent}
ForegroundInactive={subtext}
ForegroundLink={accent2}
ForegroundNegative={red}
ForegroundNeutral={yellow}
ForegroundNormal={text}
ForegroundPositive={green}
ForegroundVisited={accent2}

[Colors:View]
BackgroundAlternate={surface}
BackgroundNormal={mantle}
DecorationFocus={accent}
DecorationHover={accent2}
ForegroundActive={accent}
ForegroundInactive={subtext}
ForegroundLink={accent2}
ForegroundNegative={red}
ForegroundNeutral={yellow}
ForegroundNormal={text}
ForegroundPositive={green}
ForegroundVisited={accent2}

[Colors:Window]
BackgroundAlternate={surface}
BackgroundNormal={base}
DecorationFocus={accent}
DecorationHover={accent2}
ForegroundActive={accent}
ForegroundInactive={subtext}
ForegroundLink={accent2}
ForegroundNegative={red}
ForegroundNeutral={yellow}
ForegroundNormal={text}
ForegroundPositive={green}
ForegroundVisited={accent2}

[ColorEffects:Disabled]
Color={border}
ColorAmount=0
ColorEffect=0
ContrastAmount=0.65
ContrastEffect=1
IntensityAmount=0.1
IntensityEffect=2

[ColorEffects:Inactive]
Color={border}
ColorAmount=0
ColorEffect=0
ContrastAmount=0
ContrastEffect=0
IntensityAmount=0
IntensityEffect=0

[WM]
activeBackground={surface}
activeForeground={text}
inactiveBackground={base}
inactiveForeground={subtext}
"""


def render_foot_ini(palette: dict[str, str]) -> str:
    term = terminal_palette(palette)

    colors = f"""alpha=1.0
foreground={term["foreground"].lstrip("#")}
background={term["background"].lstrip("#")}
regular0={term["regular0"].lstrip("#")}
regular1={term["regular1"].lstrip("#")}
regular2={term["regular2"].lstrip("#")}
regular3={term["regular3"].lstrip("#")}
regular4={term["regular4"].lstrip("#")}
regular5={term["regular5"].lstrip("#")}
regular6={term["regular6"].lstrip("#")}
regular7={term["regular7"].lstrip("#")}
bright0={term["bright0"].lstrip("#")}
bright1={term["bright1"].lstrip("#")}
bright2={term["bright2"].lstrip("#")}
bright3={term["bright3"].lstrip("#")}
bright4={term["bright4"].lstrip("#")}
bright5={term["bright5"].lstrip("#")}
bright6={term["bright6"].lstrip("#")}
bright7={term["bright7"].lstrip("#")}
selection-foreground={term["selection_foreground"].lstrip("#")}
selection-background={term["selection_background"].lstrip("#")}"""

    return f"""[colors-dark]
{colors}
"""


def render_kitty_conf(palette: dict[str, str]) -> str:
    term = terminal_palette(palette)

    return f"""foreground {term["foreground"]}
background {term["background"]}
selection_foreground {term["selection_foreground"]}
selection_background {term["selection_background"]}
cursor {term["cursor"]}
cursor_text_color {term["background"]}
active_border_color {palette["accent"]}
inactive_border_color {palette["border"]}
color0 {term["regular0"]}
color1 {term["regular1"]}
color2 {term["regular2"]}
color3 {term["regular3"]}
color4 {term["regular4"]}
color5 {term["regular5"]}
color6 {term["regular6"]}
color7 {term["regular7"]}
color8 {term["bright0"]}
color9 {term["bright1"]}
color10 {term["bright2"]}
color11 {term["bright3"]}
color12 {term["bright4"]}
color13 {term["bright5"]}
color14 {term["bright6"]}
color15 #ffffff
"""


def render_terminal_sequences(palette: dict[str, str]) -> str:
    term = terminal_palette(palette)
    values = [
        term["regular0"],
        term["regular1"],
        term["regular2"],
        term["regular3"],
        term["regular4"],
        term["regular5"],
        term["regular6"],
        term["regular7"],
        term["bright0"],
        term["bright1"],
        term["bright2"],
        term["bright3"],
        term["bright4"],
        term["bright5"],
        term["bright6"],
        term["bright7"],
    ]

    seq = []
    for index, color in enumerate(values):
        seq.append(f"\033]4;{index};{color}\033\\")
    seq.append(f"\033]10;{term['foreground']}\033\\")
    seq.append(f"\033]11;[100]{term['background']}\033\\")
    seq.append(f"\033]12;{term['cursor']}\033\\")
    seq.append(f"\033]13;{term['cursor']}\033\\")
    seq.append(f"\033]17;{term['foreground']}\033\\")
    seq.append(f"\033]19;{term['background']}\033\\")
    seq.append(f"\033]4;232;{term['background']}\033\\")
    seq.append(f"\033]4;256;{term['foreground']}\033\\")
    seq.append(f"\033]4;257;{term['background']}\033\\")
    seq.append(f"\033]708;[100]{term['background']}\033\\")
    return "".join(seq)


def render_pywal_colors_sh(palette: dict[str, str], wallpaper: str) -> str:
    term = terminal_palette(palette)

    lines = [
        "# Shell variables",
        "# Generated by Quickshell theme runtime",
        f'wallpaper="{wallpaper}"',
        "",
        "# Special",
        f"background='{term['background']}'",
        f"foreground='{term['foreground']}'",
        f"cursor='{term['cursor']}'",
        "",
        "# Colors",
    ]

    values = [
        term["regular0"],
        term["regular1"],
        term["regular2"],
        term["regular3"],
        term["regular4"],
        term["regular5"],
        term["regular6"],
        term["regular7"],
        term["bright0"],
        term["bright1"],
        term["bright2"],
        term["bright3"],
        term["bright4"],
        term["bright5"],
        term["bright6"],
        term["bright7"],
    ]
    for index, color in enumerate(values):
        lines.append(f"color{index}='{color}'")

    lines.extend([
        "",
        "# FZF colors",
        'export FZF_DEFAULT_OPTS="',
        '    $FZF_DEFAULT_OPTS',
        "    --color fg:7,bg:0,hl:1,fg+:232,bg+:1,hl+:255",
        "    --color info:7,prompt:2,spinner:1,pointer:232,marker:1",
        '"',
        "",
        "# Fix LS_COLORS being unreadable.",
        'export LS_COLORS="${LS_COLORS}:su=30;41:ow=30;42:st=30;44:"',
        "",
    ])
    return "\n".join(lines)


def render_pywal_foot_ini(palette: dict[str, str]) -> str:
    term = terminal_palette(palette)

    return f"""[colors]
background={term["background"].lstrip("#")}
foreground={term["foreground"].lstrip("#")}
regular0={term["regular0"].lstrip("#")}
regular1={term["regular1"].lstrip("#")}
regular2={term["regular2"].lstrip("#")}
regular3={term["regular3"].lstrip("#")}
regular4={term["regular4"].lstrip("#")}
regular5={term["regular5"].lstrip("#")}
regular6={term["regular6"].lstrip("#")}
regular7={term["regular7"].lstrip("#")}
bright0={term["bright0"].lstrip("#")}
bright1={term["bright1"].lstrip("#")}
bright2={term["bright2"].lstrip("#")}
bright3={term["bright3"].lstrip("#")}
bright4={term["bright4"].lstrip("#")}
bright5={term["bright5"].lstrip("#")}
bright6={term["bright6"].lstrip("#")}
bright7={term["bright7"].lstrip("#")}
alpha=1.0
"""


def render_zsh_prompt(palette: dict[str, str]) -> str:
    term = terminal_palette(palette)
    success_arrow = term["regular4"]
    failure_arrow = term["regular1"]
    path_color = mix_hex(palette["accent"], palette["text"], 0.35)

    return f"""autoload -U colors && colors

# Runtime prompt generated by Quickshell.
PROMPT='%(?:%F{{{success_arrow}}}➜%f:%F{{{failure_arrow}}}➜%f) %F{{{path_color}}}%1~%f '
"""


def main() -> int:
    palette_file = STATE_HOME / "quickshell/theme/palette.json"
    palette = json.loads(palette_file.read_text(encoding="utf-8"))
    wallpaper = current_wallpaper_path()

    gtk3_dir = CONFIG_HOME / "gtk-3.0"
    gtk4_dir = CONFIG_HOME / "gtk-4.0"
    kde_dir = DATA_HOME / "color-schemes"
    terminal_dir = CONFIG_HOME / "quickshell/generated/terminal"
    foot_dir = CONFIG_HOME / "foot"
    kitty_dir = CONFIG_HOME / "kitty"
    wal_dir = CACHE_HOME / "wal"
    shell_dir = CONFIG_HOME / "quickshell/generated/shell"

    gtk_colors = render_gtk_colors(palette)
    foot_theme = render_foot_ini(palette)
    kitty_theme = render_kitty_conf(palette)
    terminal_sequences = render_terminal_sequences(palette)
    pywal_colors_sh = render_pywal_colors_sh(palette, wallpaper)
    pywal_foot = render_pywal_foot_ini(palette)
    zsh_prompt = render_zsh_prompt(palette)

    write_file(gtk3_dir / "colors.css", gtk_colors)
    write_file(gtk4_dir / "colors.css", gtk_colors)

    write_file(gtk3_dir / "gtk.css", '@import url("colors.css");\n')
    write_file(gtk4_dir / "gtk.css", '@import url("colors.css");\n')

    write_file(kde_dir / "QuickshellDiploma.colors", render_kde_colors(palette))
    write_file(terminal_dir / "foot.ini", foot_theme)
    write_file(terminal_dir / "kitty.conf", kitty_theme)
    write_file(terminal_dir / "sequences.txt", terminal_sequences)
    write_file(foot_dir / "quickshell-theme.ini", foot_theme)
    write_file(kitty_dir / "quickshell-theme.conf", kitty_theme)
    write_file(shell_dir / "prompt.zsh", zsh_prompt)
    write_file(wal_dir / "colors.sh", pywal_colors_sh)
    write_file(wal_dir / "sequences", terminal_sequences)
    write_file(wal_dir / "colors-foot.ini", pywal_foot)
    write_file(wal_dir / "wal", f"{wallpaper}\n")

    print(json.dumps({
        "gtk3": str(gtk3_dir / "colors.css"),
        "gtk4": str(gtk4_dir / "colors.css"),
        "kde": str(kde_dir / "QuickshellDiploma.colors"),
        "foot": str(terminal_dir / "foot.ini"),
        "kitty": str(terminal_dir / "kitty.conf"),
        "sequences": str(terminal_dir / "sequences.txt"),
        "foot_include": str(foot_dir / "quickshell-theme.ini"),
        "kitty_include": str(kitty_dir / "quickshell-theme.conf"),
        "zsh_prompt": str(shell_dir / "prompt.zsh"),
        "wal_colors_sh": str(wal_dir / "colors.sh"),
        "wal_sequences": str(wal_dir / "sequences"),
    }, ensure_ascii=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
