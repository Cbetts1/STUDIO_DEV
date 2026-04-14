#!/system/bin/sh
# Menu: Continue last build

STATE_FILE="$STATE_DIR/current_state"
LAST_BUILD_FILE="$STATE_DIR/last_build"
set_state() { echo "$1" > "$STATE_FILE"; }

show_continue() {
    echo ""
    echo "════════════════════════════════════════"
    echo "       CONTINUE MY LAST BUILD"
    echo "════════════════════════════════════════"
    last=""
    if [ -f "$LAST_BUILD_FILE" ]; then
        last=$(cat "$LAST_BUILD_FILE")
    fi
    if [ -n "$last" ]; then
        echo "  Last project: $last"
        echo ""
        echo "  1)  Resume: $last"
        echo "  2)  Pick a different project"
        echo "  0)  ← Back"
    else
        echo "  (no previous build found)"
        echo "  1)  Pick a project to continue"
        echo "  0)  ← Back"
    fi
    echo "════════════════════════════════════════"
}

INPUT="$1"

if [ -z "$INPUT" ]; then
    set_state continue
    show_continue
    exit 0
fi

case "$INPUT" in
    1)
        last=""
        [ -f "$LAST_BUILD_FILE" ] && last=$(cat "$LAST_BUILD_FILE")
        if [ -n "$last" ] && [ -d "$PROJECTS_DIR/$last" ]; then
            echo "[✓] Resuming: $last"
            echo "$last" > "$STATE_DIR/active_project"
            echo ""
            echo "  Project: $last"
            echo "  Path: $PROJECTS_DIR/$last"
            echo ""
            echo "  1) Open editor"
            echo "  2) Run project"
            echo "  0) ← Back"
        else
            set_state projects
            "$SYSTEM_ROOT/core/menus/projects.sh"
        fi
        ;;
    2) set_state projects; "$SYSTEM_ROOT/core/menus/projects.sh" ;;
    0) set_state home; "$SYSTEM_ROOT/core/menus/home.sh" ;;
    *) echo "[!] Unknown option: $INPUT"; show_continue ;;
esac
