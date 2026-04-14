#!/system/bin/sh
# Menu: Tools & Editors

STATE_FILE="$STATE_DIR/current_state"
set_state() { echo "$1" > "$STATE_FILE"; }

show_tools() {
    echo ""
    echo "════════════════════════════════════════"
    echo "         TOOLS & EDITORS"
    echo "════════════════════════════════════════"
    echo "  1)  Text editor (nano)"
    echo "  2)  File manager"
    echo "  3)  Script runner"
    echo "  4)  HTTP server (httpd)"
    echo "  5)  Package info / installed tools"
    echo "  6)  Calculator"
    echo "  7)  Base64 encoder / decoder"
    echo "  0)  ← Back"
    echo "════════════════════════════════════════"
}

INPUT="$1"

if [ -z "$INPUT" ]; then
    set_state tools
    show_tools
    exit 0
fi

case "$INPUT" in
    1)
        echo "Enter filename to edit (or press Enter for new file):"
        ;;
    2)
        echo ""
        echo "─── File Manager ──────────────────────"
        echo "Current dir: $PROJECTS_DIR"
        ls -la "$PROJECTS_DIR" 2>/dev/null || echo "  (empty)"
        echo ""
        echo "  1) List files"
        echo "  2) Create folder"
        echo "  3) Delete file"
        echo "  0) ← Back"
        ;;
    3)
        echo "Enter script path to run:"
        ;;
    4)
        PORT=8080
        echo "[!] Starting HTTP server on port $PORT…"
        if command -v httpd >/dev/null 2>&1; then
            httpd -p $PORT -h "$PROJECTS_DIR" &
            echo "[✓] HTTP server started on port $PORT"
            echo "    Serving: $PROJECTS_DIR"
        else
            echo "[✗] httpd not found. Install it via Update → Extra Tools."
        fi
        ;;
    5)
        echo ""
        echo "─── Installed Tools ───────────────────"
        for tool in sh nano python python3 node tcc curl httpd; do
            if command -v "$tool" >/dev/null 2>&1; then
                echo "  [✓] $tool"
            else
                echo "  [✗] $tool (not installed)"
            fi
        done
        ;;
    6)
        echo "Enter expression (e.g. 2+2):"
        ;;
    7)
        echo "  1) Encode text to Base64"
        echo "  2) Decode Base64 to text"
        ;;
    0) set_state home; "$SYSTEM_ROOT/core/menus/home.sh" ;;
    *) echo "[!] Unknown option: $INPUT"; show_tools ;;
esac
