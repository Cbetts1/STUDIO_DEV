#!/system/bin/sh
cat <<'TUT'
════════════════════════════════════════
    USING THE TERMINAL
════════════════════════════════════════

Studio OS has a built-in mini terminal.
Access it by typing 'terminal' or pressing
't' from the home menu.

WHAT YOU CAN DO
───────────────
• Run shell commands
• Navigate directories
• Edit files
• Execute scripts
• Run programs

EXAMPLE COMMANDS
────────────────
  ls              — list files
  ls -la          — list with details
  cd projects     — change directory
  pwd             — where am I?
  cat file.txt    — read a file
  mkdir myfolder  — make a folder
  rm file.txt     — delete a file
  sh script.sh    — run a script
  echo "text"     — print text

LIMITATIONS
───────────
• No root access (by design)
• No system modifications
• Restricted to the app sandbox
• Path: /data/data/com.studio.os/files/

LEAVING THE TERMINAL
────────────────────
  Type 'exit' to return to Studio OS

════════════════════════════════════════
TUT
