#!/system/bin/sh
# Wizard: Create a Program / Script

STEP_FILE="$STATE_DIR/wizard_prog_step"
DATA_FILE="$STATE_DIR/wizard_prog_data"

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
        echo "   PROGRAM WIZARD — Step 1 of 3"
        echo "════════════════════════════════════════"
        echo "  What is your program name?"
        set_step 2
        ;;
    2)
        [ -z "$INPUT" ] && echo "[!] Please enter a name." && exit 0
        save_data "name" "$INPUT"
        echo ""
        echo "════════════════════════════════════════"
        echo "   PROGRAM WIZARD — Step 2 of 3"
        echo "════════════════════════════════════════"
        echo "  What language?"
        echo "  1)  Shell script (.sh)"
        echo "  2)  Python (.py)"
        echo "  3)  JavaScript / Node.js (.js)"
        echo "  4)  C (compiled with TCC)"
        echo "  5)  HTML / CSS"
        set_step 3
        ;;
    3)
        name=$(get_data name)
        lang="$INPUT"
        proj_dir="$PROJECTS_DIR/$name"
        mkdir -p "$proj_dir"

        case "$lang" in
            1)
                cat > "$proj_dir/main.sh" <<SH
#!/system/bin/sh
# $name — Shell Script
echo "Hello from $name!"
SH
                chmod +x "$proj_dir/main.sh"
                mainfile="main.sh"
                run_cmd="sh main.sh"
                ;;
            2)
                cat > "$proj_dir/main.py" <<PY
#!/usr/bin/env python3
# $name
print("Hello from $name!")
PY
                mainfile="main.py"
                run_cmd="python3 main.py"
                ;;
            3)
                cat > "$proj_dir/main.js" <<JS
// $name
console.log("Hello from $name!");
JS
                mainfile="main.js"
                run_cmd="node main.js"
                ;;
            4)
                cat > "$proj_dir/main.c" <<CC
#include <stdio.h>
int main() {
    printf("Hello from $name!\n");
    return 0;
}
CC
                mainfile="main.c"
                run_cmd="tcc main.c -o main && ./main"
                ;;
            *)
                cat > "$proj_dir/index.html" <<HTML
<!DOCTYPE html><html><head><title>$name</title></head>
<body><h1>$name</h1></body></html>
HTML
                mainfile="index.html"
                run_cmd="(open in browser)"
                ;;
        esac

        cat > "$proj_dir/README.md" <<MD
# $name
Created by Studio OS Program Wizard.
Run with: $run_cmd
MD

        echo "$name" > "$STATE_DIR/last_build"
        rm -f "$STEP_FILE" "$DATA_FILE"

        echo ""
        echo "[✓] Program project created!"
        echo "  Name : $name"
        echo "  File : $mainfile"
        echo "  Run  : $run_cmd"
        echo ""
        echo "  1)  Open in editor"
        echo "  2)  Run now"
        echo "  0)  ← Back"
        ;;
esac
