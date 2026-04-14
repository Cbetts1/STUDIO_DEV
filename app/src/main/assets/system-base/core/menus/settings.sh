#!/system/bin/sh
# Menu: System Settings

STATE_FILE="$STATE_DIR/current_state"
SETTINGS_FILE="$STATE_DIR/settings"
set_state() { echo "$1" > "$STATE_FILE"; }
get_setting() { grep "^$1=" "$SETTINGS_FILE" 2>/dev/null | cut -d= -f2; }
set_setting() { 
    grep -v "^$1=" "$SETTINGS_FILE" 2>/dev/null > "$SETTINGS_FILE.tmp" 2>/dev/null
    echo "$1=$2" >> "$SETTINGS_FILE.tmp"
    mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
}

show_settings() {
    theme=$(get_setting theme); theme="${theme:-dark}"
    voice=$(get_setting voice); voice="${voice:-off}"
    cloud=$(get_setting cloud); cloud="${cloud:-off}"
    echo ""
    echo "════════════════════════════════════════"
    echo "         SYSTEM SETTINGS"
    echo "════════════════════════════════════════"
    echo "  1)  Theme          : $theme"
    echo "  2)  Voice Input    : $voice"
    echo "  3)  Cloud Sync     : $cloud"
    echo "  4)  About Studio OS"
    echo "  5)  Reset all settings"
    echo "  6)  Factory reset (wipe all data)"
    echo "  0)  ← Back"
    echo "════════════════════════════════════════"
}

INPUT="$1"

if [ -z "$INPUT" ]; then
    set_state settings
    show_settings
    exit 0
fi

case "$INPUT" in
    1)
        cur=$(get_setting theme); cur="${cur:-dark}"
        case "$cur" in
            dark)  next=oled ;;
            oled)  next=light ;;
            *)     next=dark ;;
        esac
        set_setting theme "$next"
        echo "[✓] Theme changed to: $next"
        echo "THEME:$next"
        ;;
    2)
        cur=$(get_setting voice); cur="${cur:-off}"
        next=$([ "$cur" = "on" ] && echo off || echo on)
        set_setting voice "$next"
        echo "[✓] Voice input: $next"
        ;;
    3)
        cur=$(get_setting cloud); cur="${cur:-off}"
        next=$([ "$cur" = "on" ] && echo off || echo on)
        set_setting cloud "$next"
        echo "[✓] Cloud sync: $next"
        ;;
    4)
        echo ""
        echo "─── About Studio OS ───────────────────"
        echo "  Version    : 1.0"
        echo "  Target     : Samsung Galaxy S21 FE"
        echo "  Platform   : Android 12+ ARM64"
        echo "  Engine     : POSIX shell"
        echo "  UI         : Jetpack Compose"
        echo "  Root req'd : No"
        echo "  License    : MIT"
        ;;
    5)
        rm -f "$SETTINGS_FILE"
        echo "[✓] Settings reset to defaults."
        ;;
    6)
        echo "[!] WARNING: This will delete ALL projects and data!"
        echo "    Type 'CONFIRM' to proceed, or 0 to cancel:"
        ;;
    0) set_state home; "$SYSTEM_ROOT/core/menus/home.sh" ;;
    CONFIRM)
        rm -rf "$PROJECTS_DIR"/* "$STATE_DIR"/*
        echo "home" > "$STATE_FILE"
        echo "[✓] Factory reset complete."
        "$SYSTEM_ROOT/core/menus/home.sh"
        ;;
    *) echo "[!] Unknown option: $INPUT"; show_settings ;;
esac
