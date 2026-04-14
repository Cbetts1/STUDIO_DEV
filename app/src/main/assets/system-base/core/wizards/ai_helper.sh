#!/system/bin/sh
# Wizard: Create an AI Helper / Bot

STEP_FILE="$STATE_DIR/wizard_ai_step"
DATA_FILE="$STATE_DIR/wizard_ai_data"

get_step() { cat "$STEP_FILE" 2>/dev/null || echo "1"; }
set_step()  { echo "$1" > "$STEP_FILE"; }
save_data() { echo "$1=$2" >> "$DATA_FILE"; }
get_data()  { grep "^$1=" "$DATA_FILE" 2>/dev/null | cut -d= -f2; }

INPUT="$1"
step=$(get_step)

case "$step" in
    1)
        echo ""
        echo "════════════════════════════════════════"
        echo "   AI HELPER WIZARD — Step 1 of 3"
        echo "════════════════════════════════════════"
        echo "  What is your AI helper's name?"
        set_step 2
        ;;
    2)
        [ -z "$INPUT" ] && echo "[!] Enter a name." && exit 0
        save_data "name" "$INPUT"
        echo ""
        echo "════════════════════════════════════════"
        echo "   AI HELPER WIZARD — Step 2 of 3"
        echo "════════════════════════════════════════"
        echo "  What should your AI helper do?"
        echo "  1)  Answer questions (Q&A bot)"
        echo "  2)  Task checklist assistant"
        echo "  3)  Code review helper"
        echo "  4)  Custom (blank template)"
        set_step 3
        ;;
    3)
        name=$(get_data name)
        proj_dir="$PROJECTS_DIR/$name"
        mkdir -p "$proj_dir"

        case "$INPUT" in
            1) template="qa" ;;
            2) template="checklist" ;;
            3) template="code_review" ;;
            *) template="custom" ;;
        esac

        cat > "$proj_dir/helper.sh" <<SH
#!/system/bin/sh
# $name — AI Helper (template: $template)
# This is a rule-based helper. Integrate with an AI API for smarter responses.

echo "╔══════════════════════════════╗"
echo "║  $name  ║"
echo "╚══════════════════════════════╝"
echo ""

while true; do
    printf "You: "
    read -r INPUT
    [ -z "\$INPUT" ] && continue
    [ "\$INPUT" = "exit" ] && break

    # Simple rule-based responses
    case "\$INPUT" in
        *help*|*how*)
            echo "Helper: I can assist you with $template tasks. Type your question."
            ;;
        *thank*)
            echo "Helper: You're welcome!"
            ;;
        hi|hello|hey)
            echo "Helper: Hello! How can I help you today?"
            ;;
        *)
            echo "Helper: I received your message: '\$INPUT'"
            echo "        (Connect to an AI API for smart responses)"
            ;;
    esac
done
echo "Helper: Goodbye!"
SH
        chmod +x "$proj_dir/helper.sh"

        cat > "$proj_dir/config.sh" <<CFG
# AI Helper Config for $name
HELPER_NAME="$name"
TEMPLATE="$template"
# To use a real AI API, set your API key here:
# API_KEY=""
# API_ENDPOINT=""
CFG

        echo "$name" > "$STATE_DIR/last_build"
        rm -f "$STEP_FILE" "$DATA_FILE"

        echo ""
        echo "[✓] AI Helper created!"
        echo "  Name    : $name"
        echo "  Template: $template"
        echo "  Run     : sh $proj_dir/helper.sh"
        echo ""
        echo "  1)  Run helper now"
        echo "  2)  Edit helper script"
        echo "  0)  ← Back"
        ;;
esac
