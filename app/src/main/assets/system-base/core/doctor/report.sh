#!/system/bin/sh
# Studio Doctor — View Report

REPORT_FILE="$STATE_DIR/doctor_report.txt"

echo ""
echo "════════════════════════════════════════"
echo "       STUDIO DOCTOR — REPORT"
echo "════════════════════════════════════════"

if [ -f "$REPORT_FILE" ]; then
    cat "$REPORT_FILE"
else
    echo "  No report found. Run Studio Doctor first."
fi

echo "════════════════════════════════════════"
echo "  0)  ← Back"
