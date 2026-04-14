#!/system/bin/sh
# Tutorial: Shell scripting

cat <<'TUT'
════════════════════════════════════════
    HOW TO WRITE A SHELL SCRIPT
════════════════════════════════════════

A shell script is a list of commands that
run one after another. Studio OS uses the
Android system shell (/system/bin/sh).

EXAMPLE SCRIPT
──────────────
#!/system/bin/sh
# My first script
echo "Hello, World!"
name="Studio OS"
echo "Running on $name"

HOW TO CREATE ONE
─────────────────
1. Home → Create → Program / Script
2. Choose 'Shell script'
3. Give it a name
4. Use Tools → Editor to edit it
5. Run with: sh yourscript.sh

USEFUL COMMANDS
───────────────
echo "text"     — print text
read VAR        — get user input
if / then / fi  — conditionals
for i in ...    — loops
mkdir / rm / mv — file operations
cat file.txt    — read a file
grep pattern f  — search in file

TIPS
────
• Every script should start with #!/system/bin/sh
• Use # for comments
• Variables: NAME="value"  →  echo $NAME

════════════════════════════════════════
TUT
