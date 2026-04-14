#!/system/bin/sh
# Menu: Open my projects

STATE_FILE="$STATE_DIR/current_state"
set_state() { echo "$1" > "$STATE_FILE"; }

show_projects() {
    echo ""
    echo "════════════════════════════════════════"
    echo "         MY PROJECTS"
    echo "════════════════════════════════════════"
    count=0
    if [ -d "$PROJECTS_DIR" ]; then
        for proj in "$PROJECTS_DIR"/*/; do
            if [ -d "$proj" ]; then
                count=$((count + 1))
                name=$(basename "$proj")
                echo "  $count)  $name"
            fi
        done
    fi
    if [ "$count" -eq 0 ]; then
        echo "  (no projects yet — create one first)"
    fi
    echo "  0)  ← Back"
    echo "════════════════════════════════════════"
}

INPUT="$1"

if [ -z "$INPUT" ]; then
    set_state projects
    show_projects
    exit 0
fi

case "$INPUT" in
    0) set_state home; "$SYSTEM_ROOT/core/menus/home.sh" ;;
    *)
        # Try to open project by index
        idx=0
        for proj in "$PROJECTS_DIR"/*/; do
            if [ -d "$proj" ]; then
                idx=$((idx + 1))
                if [ "$idx" = "$INPUT" ]; then
                    name=$(basename "$proj")
                    echo ""
                    echo "[✓] Opening project: $name"
                    echo "  Path: $proj"
                    echo ""
                    echo "  1) Edit files (nano)"
                    echo "  2) Run project"
                    echo "  3) Delete project"
                    echo "  0) ← Back"
                    echo "Project: $name" > "$STATE_DIR/active_project"
                    exit 0
                fi
            fi
        done
        echo "[!] Unknown option: $INPUT"
        show_projects
        ;;
esac
