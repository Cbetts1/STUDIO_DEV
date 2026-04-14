#!/system/bin/sh
# Menu: Home

STATE_FILE="$STATE_DIR/current_state"
set_state() { echo "$1" > "$STATE_FILE"; }

show_home() {
    echo ""
    echo "════════════════════════════════════════"
    echo "              STUDIO OS"
    echo "════════════════════════════════════════"
    echo "  1)  Create something new"
    echo "  2)  Open my projects"
    echo "  3)  Fix a problem"
    echo "  4)  Continue my last build"
    echo "  5)  Update / improve Studio OS"
    echo "  6)  Tools & Editors"
    echo "  7)  System Settings"
    echo "  8)  Learn / Tutorials"
    echo "  9)  Studio Doctor (scan & repair)"
    echo "  t)  Terminal"
    echo "  q)  Quit"
    echo "════════════════════════════════════════"
    echo "Type a number (or ? for help):"
}

INPUT="$1"

if [ -z "$INPUT" ]; then
    set_state home
    show_home
    exit 0
fi

case "$INPUT" in
    1) set_state create;    "$SYSTEM_ROOT/core/menus/create.sh" ;;
    2) set_state projects;  "$SYSTEM_ROOT/core/menus/projects.sh" ;;
    3) set_state fix;       "$SYSTEM_ROOT/core/menus/fix.sh" ;;
    4) set_state continue;  "$SYSTEM_ROOT/core/menus/continue.sh" ;;
    5) set_state update;    "$SYSTEM_ROOT/core/menus/update.sh" ;;
    6) set_state tools;     "$SYSTEM_ROOT/core/menus/tools.sh" ;;
    7) set_state settings;  "$SYSTEM_ROOT/core/menus/settings.sh" ;;
    8) set_state tutorials; "$SYSTEM_ROOT/core/menus/tutorials.sh" ;;
    9) set_state fix;       "$SYSTEM_ROOT/core/doctor/scan.sh" ;;
    t|terminal) set_state terminal; "$SYSTEM_ROOT/core/menus/terminal.sh" ;;
    q|quit|exit) echo "Goodbye."; exit 0 ;;
    *) echo "[!] Unknown option: $INPUT"; show_home ;;
esac
