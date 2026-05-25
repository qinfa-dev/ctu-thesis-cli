#!/usr/bin/env bash
set -euo pipefail
# Template sync test — validates compliance.json ↔ info.typ consistency
# Run in CI to prevent format drift

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/../templates"
failures=0

echo "=== Checking compliance.json ↔ info.typ consistency ==="

COMPLIANCE="$TEMPLATES_DIR/compliance.json"
INFO="$TEMPLATES_DIR/info.typ"

if [[ ! -f "$COMPLIANCE" ]]; then
  echo "FAIL: compliance.json not found at $COMPLIANCE"
  exit 1
fi
if [[ ! -f "$INFO" ]]; then
  echo "FAIL: info.typ not found at $INFO"
  exit 1
fi

# Check font
FONT_JSON=$(grep -oP '"font":\s*"\K[^"]+' "$COMPLIANCE" | head -1 || true)
FONT_TYPST=$(grep -oP 'font:\s*"\K[^"]+' "$INFO" | head -1 || true)
if [[ "$FONT_JSON" != "$FONT_TYPST" ]]; then
  echo "FAIL: font mismatch — compliance.json=$FONT_JSON, info.typ=$FONT_TYPST"
  ((failures++))
else
  echo "OK: font = $FONT_JSON"
fi

# Check margins
MARGIN_LEFT_JSON=$(grep -oP '"left":\s*"\K[^"]+' "$COMPLIANCE" | head -1 || true)
MARGIN_LEFT_TYPST=$(grep -oP 'left:\s*\K[0-9.]+cm' "$INFO" | head -1 || true)
if [[ "$MARGIN_LEFT_JSON" != "$MARGIN_LEFT_TYPST" ]]; then
  echo "FAIL: margin.left mismatch — compliance.json=$MARGIN_LEFT_JSON, info.typ=$MARGIN_LEFT_TYPST"
  ((failures++))
else
  echo "OK: margin.left = $MARGIN_LEFT_JSON"
fi

# Check line spacing
SPACING_JSON=$(grep -oP '"line_spacing":\s*\K[0-9.]+' "$COMPLIANCE" | head -1 || true)
SPACING_TYPST=$(grep -oP 'line_spacing:\s*\K[0-9.]+' "$INFO" | head -1 || true)
if [[ "$SPACING_JSON" != "$SPACING_TYPST" ]]; then
  echo "FAIL: line_spacing mismatch"
  ((failures++))
else
  echo "OK: line_spacing = $SPACING_JSON"
fi

# Check paragraph indent
INDENT_JSON=$(grep -oP '"paragraph_indent":\s*"\K[^"]+' "$COMPLIANCE" | head -1 || true)
INDENT_TYPST=$(grep -oP 'paragraph_indent:\s*\K[0-9.]+cm' "$INFO" | head -1 || true)
if [[ "$INDENT_JSON" != "$INDENT_TYPST" ]]; then
  echo "FAIL: paragraph_indent mismatch"
  ((failures++))
else
  echo "OK: paragraph_indent = $INDENT_JSON"
fi

if [[ $failures -gt 0 ]]; then
  echo ""
  echo "FAIL: $failures sync error(s). Update compliance.json to match info.typ."
  exit 1
fi

echo ""
echo "OK: compliance.json and info.typ are in sync."
exit 0
