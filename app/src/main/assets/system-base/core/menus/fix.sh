#!/system/bin/sh
# Menu: Fix a problem

STATE_FILE="$STATE_DIR/current_state"
set_state() { echo "$1" > "$STATE_FILE"; }

show_fix() {
    echo ""
    echo "════════════════════════════════════════"
    echo "         FIX A PROBLEM"
    echo "════════════════════════════════════════"
    echo "  1)  Run Studio Doctor (full scan)"
    echo "  2)  Check disk usage"
    echo "  3)  Clear temp files"
    echo "  4)  Reset a project"
    echo "  5)  View error log"
    echo "  0)  ← Back"
    echo "════════════════════════════════════════"
}

INPUT="$1"

if [ -z "$INPUT" ]; then
    set_state fix
    show_fix
    exit 0
fi

case "$INPUT" in
    1) "$SYSTEM_ROOT/core/doctor/scan.sh" ;;
    2)
        echo ""
        echo "─── Disk Usage ─────────────────────────"
        du -sh "$SYSTEM_ROOT" 2>/dev/null && echo ""
        du -sh "$PROJECTS_DIR" 2>/dev/null && echo ""
        ;;
    3)
        echo "[!] Clearing temp files…"
        rm -rf "$SYSTEM_ROOT/state/tmp" 2>/dev/null
        mkdir -p "$SYSTEM_ROOT/state/tmp"
        echo "[✓] Done."
        ;;
    4)
        echo "Enter project name to reset (or 0 to cancel):"
        ;;
    5)
        echo ""
        echo "─── Error Log ──────────────────────────"
        if [ -f "$STATE_DIR/error.log" ]; then
            tail -50 "$STATE_DIR/error.log"
        else
            echo "  (no errors logged)"
        fi
        ;;
    0) set_state home; "$SYSTEM_ROOT/core/menus/home.sh" ;;
    *) echo "[!] Unknown option: $INPUT"; show_fix ;;
esac
