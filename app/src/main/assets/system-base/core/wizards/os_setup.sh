#!/system/bin/sh
# Wizard: Custom OS Setup

STEP_FILE="$STATE_DIR/wizard_os_step"
DATA_FILE="$STATE_DIR/wizard_os_data"

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
        echo "   OS SETUP WIZARD — Step 1 of 3"
        echo "════════════════════════════════════════"
        echo "  Name your custom OS environment:"
        set_step 2
        ;;
    2)
        [ -z "$INPUT" ] && echo "[!] Enter a name." && exit 0
        save_data "name" "$INPUT"
        echo ""
        echo "════════════════════════════════════════"
        echo "   OS SETUP WIZARD — Step 2 of 3"
        echo "════════════════════════════════════════"
        echo "  Choose a starter profile:"
        echo "  1)  Developer  (shell + editors)"
        echo "  2)  Web server (httpd + html)"
        echo "  3)  Minimal    (shell only)"
        echo "  4)  Custom     (blank)"
        set_step 3
        ;;
    3)
        name=$(get_data name)
        profile="$INPUT"
        proj_dir="$PROJECTS_DIR/$name"
        mkdir -p "$proj_dir/bin" "$proj_dir/etc" "$proj_dir/home"

        case "$profile" in
            1) profile_name="developer" ;;
            2) profile_name="web-server" ;;
            3) profile_name="minimal" ;;
            *) profile_name="custom" ;;
        esac

        cat > "$proj_dir/etc/profile" <<PROFILE
# $name OS Profile — $profile_name
export OS_NAME="$name"
export OS_PROFILE="$profile_name"
export PATH="\$PATH:$proj_dir/bin"
export HOME="$proj_dir/home"
PROFILE

        cat > "$proj_dir/boot.sh" <<BOOT
#!/system/bin/sh
# Boot script for $name
. "$proj_dir/etc/profile"
echo "═══════════════════════════"
echo "  $name OS"
echo "  Profile: $profile_name"
echo "═══════════════════════════"
echo "  Type commands or 'exit' to stop."
cd "\$HOME"
while true; do
    printf "[$name]\\$ "
    read -r CMD
    [ "\$CMD" = "exit" ] && break
    eval "\$CMD" 2>&1 || true
done
BOOT
        chmod +x "$proj_dir/boot.sh"

        echo "$name" > "$STATE_DIR/last_build"
        rm -f "$STEP_FILE" "$DATA_FILE"

        echo ""
        echo "[✓] OS environment created!"
        echo "  Name   : $name"
        echo "  Profile: $profile_name"
        echo "  Path   : $proj_dir"
        echo ""
        echo "  1)  Boot into $name"
        echo "  2)  Edit profile"
        echo "  0)  ← Back"
        ;;
esac
