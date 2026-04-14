#!/system/bin/sh
# Menu: Mini Terminal

STATE_FILE="$STATE_DIR/current_state"
set_state() { echo "$1" > "$STATE_FILE"; }

set_state terminal

echo ""
echo "════════════════════════════════════════"
echo "   STUDIO OS TERMINAL  (sandbox shell)"
echo "════════════════════════════════════════"
echo "  Type shell commands. 'exit' to leave."
echo "  Working dir: $PROJECTS_DIR"
echo "════════════════════════════════════════"
echo ""

cd "$PROJECTS_DIR" 2>/dev/null || cd "$HOME"

while true; do
    printf "\$ "
    if ! read -r CMD; then
        break
    fi
    case "$CMD" in
        exit|quit) break ;;
        "") continue ;;
        cd\ *)
            target="${CMD#cd }"
            if ! cd "$target" 2>/dev/null; then
                echo "[✗] cd: no such directory: $target"
            fi
            ;;
        *)
            eval "$CMD" 2>&1 || true
            ;;
    esac
done

set_state home
echo ""
echo "[✓] Returned to Studio OS home."
"$SYSTEM_ROOT/core/menus/home.sh"
