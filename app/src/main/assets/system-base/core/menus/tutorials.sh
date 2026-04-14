#!/system/bin/sh
# Menu: Tutorials

STATE_FILE="$STATE_DIR/current_state"
TUTORIALS_DIR="$SYSTEM_ROOT/core/tutorials"
set_state() { echo "$1" > "$STATE_FILE"; }

show_tutorials() {
    echo ""
    echo "════════════════════════════════════════"
    echo "         LEARN / TUTORIALS"
    echo "════════════════════════════════════════"
    echo "  1)  Getting started"
    echo "  2)  How to create a website"
    echo "  3)  How to write a shell script"
    echo "  4)  How to use the editor"
    echo "  5)  How to run an AI helper"
    echo "  6)  Using the terminal"
    echo "  7)  Understanding projects"
    echo "  0)  ← Back"
    echo "════════════════════════════════════════"
}

INPUT="$1"

if [ -z "$INPUT" ]; then
    set_state tutorials
    show_tutorials
    exit 0
fi

case "$INPUT" in
    1) "$TUTORIALS_DIR/getting_started.sh" ;;
    2) "$TUTORIALS_DIR/website.sh" ;;
    3) "$TUTORIALS_DIR/shell_script.sh" ;;
    4) "$TUTORIALS_DIR/editor.sh" ;;
    5) "$TUTORIALS_DIR/ai_helper.sh" ;;
    6) "$TUTORIALS_DIR/terminal.sh" ;;
    7) "$TUTORIALS_DIR/projects.sh" ;;
    0) set_state home; "$SYSTEM_ROOT/core/menus/home.sh" ;;
    *) echo "[!] Unknown option: $INPUT"; show_tutorials ;;
esac
