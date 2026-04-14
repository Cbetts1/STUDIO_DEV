#!/system/bin/sh
# Wizard: Create a Website / Web App

STEP_FILE="$STATE_DIR/wizard_website_step"
DATA_FILE="$STATE_DIR/wizard_website_data"

get_step() { cat "$STEP_FILE" 2>/dev/null || echo "1"; }
set_step() { echo "$1" > "$STEP_FILE"; }
save_data() { echo "$1=$2" >> "$DATA_FILE"; }
get_data()  { grep "^$1=" "$DATA_FILE" 2>/dev/null | cut -d= -f2; }

INPUT="$1"
step=$(get_step)

case "$step" in
    1)
        echo ""
        echo "════════════════════════════════════════"
        echo "   WEBSITE WIZARD — Step 1 of 4"
        echo "════════════════════════════════════════"
        echo "  What is your project name?"
        echo "  (e.g. my-site, portfolio, blog)"
        echo ""
        echo "  Type the name and press Enter:"
        set_step 2
        ;;
    2)
        if [ -z "$INPUT" ]; then echo "[!] Please enter a project name."; exit 0; fi
        save_data "name" "$INPUT"
        echo ""
        echo "════════════════════════════════════════"
        echo "   WEBSITE WIZARD — Step 2 of 4"
        echo "════════════════════════════════════════"
        echo "  What type of website?"
        echo "  1)  Simple HTML page"
        echo "  2)  Portfolio / personal site"
        echo "  3)  Blog"
        echo "  4)  Landing page"
        echo "  5)  Blank (just index.html)"
        set_step 3
        ;;
    3)
        save_data "type" "$INPUT"
        echo ""
        echo "════════════════════════════════════════"
        echo "   WEBSITE WIZARD — Step 3 of 4"
        echo "════════════════════════════════════════"
        echo "  What is your site title?"
        set_step 4
        ;;
    4)
        save_data "title" "$INPUT"
        # Build the project
        name=$(get_data name)
        type=$(get_data type)
        title=$(get_data title)
        proj_dir="$PROJECTS_DIR/$name"
        mkdir -p "$proj_dir"

        cat > "$proj_dir/index.html" <<HTML
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$title</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: sans-serif; background: #0d0d0d; color: #e0e0e0; padding: 2rem; }
    h1 { color: #00e5ff; margin-bottom: 1rem; }
    p  { color: #aaa; line-height: 1.6; }
    a  { color: #00e5ff; }
  </style>
</head>
<body>
  <h1>$title</h1>
  <p>Welcome to your new website. Edit <code>index.html</code> to get started.</p>
</body>
</html>
HTML

        cat > "$proj_dir/README.md" <<MD
# $title

Created by Studio OS Website Wizard.

## How to run
Open this project in Tools → HTTP Server, then open a browser to http://localhost:8080

## Files
- index.html — main page
MD

        echo "name=$name" > "$STATE_DIR/last_build"
        rm -f "$STEP_FILE" "$DATA_FILE"

        echo ""
        echo "[✓] Website project created!"
        echo "  Name : $name"
        echo "  Path : $proj_dir"
        echo "  Files: index.html, README.md"
        echo ""
        echo "  1)  Open editor to edit index.html"
        echo "  2)  Start HTTP server to preview"
        echo "  0)  ← Back to home"
        ;;
esac
