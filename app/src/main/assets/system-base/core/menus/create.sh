#!/system/bin/sh
# Menu: Create something new

STATE_FILE="$STATE_DIR/current_state"
set_state() { echo "$1" > "$STATE_FILE"; }

show_create() {
    echo ""
    echo "════════════════════════════════════════"
    echo "       CREATE SOMETHING NEW"
    echo "════════════════════════════════════════"
    echo "  1)  Website / Web App"
    echo "  2)  Program / Script"
    echo "  3)  AI Helper / Bot"
    echo "  4)  Custom OS Setup"
    echo "  5)  Blank Project"
    echo "  0)  ← Back"
    echo "════════════════════════════════════════"
}

INPUT="$1"

if [ -z "$INPUT" ]; then
    set_state create
    show_create
    exit 0
fi

case "$INPUT" in
    1) "$SYSTEM_ROOT/core/wizards/website.sh" ;;
    2) "$SYSTEM_ROOT/core/wizards/program.sh" ;;
    3) "$SYSTEM_ROOT/core/wizards/ai_helper.sh" ;;
    4) "$SYSTEM_ROOT/core/wizards/os_setup.sh" ;;
    5) "$SYSTEM_ROOT/core/wizards/blank_project.sh" ;;
    0) set_state home; "$SYSTEM_ROOT/core/menus/home.sh" ;;
    *) echo "[!] Unknown option: $INPUT"; show_create ;;
esac
