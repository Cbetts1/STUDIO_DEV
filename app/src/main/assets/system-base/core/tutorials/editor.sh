#!/system/bin/sh
cat <<'TUT'
════════════════════════════════════════
    HOW TO USE THE EDITOR
════════════════════════════════════════

Studio OS uses the built-in text editor.
In the terminal, you can also use 'nano'
if it is installed.

OPENING THE EDITOR
──────────────────
• Go to Tools & Editors → Text Editor
• Enter the filename you want to edit
• The file will open for editing

BASIC NANO SHORTCUTS (if nano is present)
──────────────────────────────────────────
  Ctrl+O    Save file
  Ctrl+X    Exit
  Ctrl+K    Cut line
  Ctrl+U    Paste line
  Ctrl+W    Search
  Ctrl+G    Help

WITHOUT NANO
────────────
You can also create/edit files using shell
commands in the terminal:

  echo "my text" > file.txt    (create)
  cat file.txt                  (view)
  cat >> file.txt               (append)

════════════════════════════════════════
TUT
