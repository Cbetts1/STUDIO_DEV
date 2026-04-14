#!/system/bin/sh
# Studio Doctor — Full System Scan

REPORT_FILE="$STATE_DIR/doctor_report.txt"
PASS=0; WARN=0; FAIL=0

ok()   { echo "[✓] $1"; echo "PASS: $1" >> "$REPORT_FILE"; PASS=$((PASS+1)); }
warn() { echo "[!] $1"; echo "WARN: $1" >> "$REPORT_FILE"; WARN=$((WARN+1)); }
fail() { echo "[✗] $1"; echo "FAIL: $1" >> "$REPORT_FILE"; FAIL=$((FAIL+1)); }

echo "" > "$REPORT_FILE"
echo "════════════════════════════════════════"
echo "       STUDIO DOCTOR — SCANNING…"
echo "════════════════════════════════════════"
echo ""
echo "▶ Checking environment…"

# Check SYSTEM_ROOT
if [ -n "$SYSTEM_ROOT" ] && [ -d "$SYSTEM_ROOT" ]; then
    ok "SYSTEM_ROOT is set: $SYSTEM_ROOT"
else
    fail "SYSTEM_ROOT not set or missing"
fi

# Check STATE_DIR
if [ -d "$STATE_DIR" ]; then
    ok "STATE_DIR exists: $STATE_DIR"
else
    warn "STATE_DIR missing — creating…"
    mkdir -p "$STATE_DIR" && ok "STATE_DIR created" || fail "Could not create STATE_DIR"
fi

# Check PROJECTS_DIR
if [ -d "$PROJECTS_DIR" ]; then
    ok "PROJECTS_DIR exists: $PROJECTS_DIR"
else
    warn "PROJECTS_DIR missing — creating…"
    mkdir -p "$PROJECTS_DIR" && ok "PROJECTS_DIR created" || fail "Could not create PROJECTS_DIR"
fi

echo ""
echo "▶ Checking shell scripts…"

for script in \
    "$SYSTEM_ROOT/core/boot" \
    "$SYSTEM_ROOT/core/shell" \
    "$SYSTEM_ROOT/core/menus/home.sh" \
    "$SYSTEM_ROOT/core/menus/create.sh" \
    "$SYSTEM_ROOT/core/menus/tools.sh"; do
    if [ -f "$script" ]; then
        ok "Found: $(basename $script)"
    else
        fail "Missing: $script"
    fi
done

echo ""
echo "▶ Checking available tools…"

for tool in sh cat ls mkdir rm cp mv echo; do
    if command -v "$tool" >/dev/null 2>&1; then
        ok "Tool available: $tool"
    else
        warn "Tool missing: $tool (may not be available in sandbox)"
    fi
done

echo ""
echo "▶ Checking optional tools…"
for tool in python python3 node nano curl; do
    if command -v "$tool" >/dev/null 2>&1; then
        ok "Optional tool: $tool"
    else
        warn "Optional tool not found: $tool"
    fi
done

echo ""
echo "▶ Checking disk space…"
avail=$(df "$SYSTEM_ROOT" 2>/dev/null | awk 'NR==2{print $4}')
if [ -n "$avail" ] && [ "$avail" -gt 10240 ] 2>/dev/null; then
    ok "Disk space OK: ${avail}K available"
elif [ -n "$avail" ]; then
    warn "Low disk space: ${avail}K available"
fi

echo ""
echo "▶ Checking state…"
if [ -f "$STATE_DIR/current_state" ]; then
    st=$(cat "$STATE_DIR/current_state")
    ok "State file: current_state = $st"
else
    warn "State file missing — will be created on next start"
fi

echo ""
echo "════════════════════════════════════════"
echo "  SCAN COMPLETE"
printf "  ✓ %d passed  " "$PASS"
printf "! %d warnings  " "$WARN"
printf "✗ %d failures\n" "$FAIL"
echo "════════════════════════════════════════"
echo ""

if [ "$FAIL" -gt 0 ]; then
    echo "[!] Issues found. Run 'Fix a problem' for guided repair."
elif [ "$WARN" -gt 0 ]; then
    echo "[!] Minor warnings found. Studio OS should still work."
else
    echo "[✓] All checks passed. Studio OS is healthy!"
fi
echo ""
echo "  Full report saved to: $REPORT_FILE"
echo ""
echo "  1)  View full report"
echo "  2)  Auto-fix issues"
echo "  0)  ← Back"
