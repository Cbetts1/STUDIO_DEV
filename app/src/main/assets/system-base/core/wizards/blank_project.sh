#!/system/bin/sh
# Wizard: Blank Project

INPUT="$1"
STEP_FILE="$STATE_DIR/wizard_blank_step"

get_step() { cat "$STEP_FILE" 2>/dev/null || echo "1"; }
set_step()  { echo "$1" > "$STEP_FILE"; }

step=$(get_step)

case "$step" in
    1)
        echo ""
        echo "════════════════════════════════════════"
        echo "   NEW BLANK PROJECT"
        echo "════════════════════════════════════════"
        echo "  Enter project name:"
        set_step 2
        ;;
    2)
        [ -z "$INPUT" ] && echo "[!] Enter a name." && exit 0
        proj_dir="$PROJECTS_DIR/$INPUT"
        mkdir -p "$proj_dir"
        cat > "$proj_dir/README.md" <<MD
# $INPUT

A blank Studio OS project.
MD
        echo "$INPUT" > "$STATE_DIR/last_build"
        rm -f "$STEP_FILE"
        echo ""
        echo "[✓] Blank project created: $INPUT"
        echo "  Path: $proj_dir"
        echo ""
        echo "  1)  Open editor"
        echo "  0)  ← Back"
        ;;
esac
