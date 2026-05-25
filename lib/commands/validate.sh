#!/usr/bin/env bash
# validate — check CTU guideline compliance

ctu_help_validate() {
  echo "Usage: ctu-thesis validate [OPTIONS]"
  echo ""
  echo "Check thesis project against CTU formatting guidelines."
  echo "Must be run from within a thesis project directory."
  echo ""
  echo "Options:"
  echo "  --fix     Auto-repair simple issues (missing dirs, empty .bib)"
  echo ""
  echo "Exit codes: 0=pass, 4=validation failed"
}

# Validate: Run CTU guideline compliance checks on the thesis project
ctu_validate() {
  local fix_mode=false
  local root="$PWD"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --fix) fix_mode=true; shift ;;
      *) shift ;;
    esac
  done

  # Find: Locate project root or fall back to current directory with info.typ
  if ! root=$(ctu_find_project_root); then
    if [[ ! -f "$PWD/info.typ" ]]; then
      ctu_log_error "Not in a thesis project directory."
      return 4
    fi
    root="$PWD"
  fi
  cd "$root" || return 1

  local failures=0
  local warnings=0

  ctu_log_info "Validating thesis project..."
  echo ""

  # Check: Required structure files (main.typ, info.typ, mandatory directories)
  echo "--- Structure ---"

  if [[ -f "main.typ" ]]; then
    ctu_log_ok "main.typ found"
  else
    ctu_log_error "main.typ missing"
    failures=$((failures + 1))
  fi

  if [[ -f "info.typ" ]]; then
    ctu_log_ok "info.typ found"
  else
    ctu_log_error "info.typ missing"
    failures=$((failures + 1))
  fi

  local req_dirs=("template" "frontmatter" "chapters" "backmatter" "images")
  for d in "${req_dirs[@]}"; do
    if [[ -d "$d" ]]; then
      ctu_log_ok "  directory: $d"
    else
      if [[ "$fix_mode" == "true" ]]; then
        # Fix: Create missing directory with --fix
        mkdir -p "$d"
        ctu_log_warn "  created: $d"
      else
        ctu_log_error "  missing directory: $d"
        failures=$((failures + 1))
      fi
    fi
  done

  echo ""
  echo "--- Metadata ---"

  if [[ -f "info.typ" ]]; then
    # Check: Required metadata keys exist in info.typ
    local required_keys=("student" "advisor" "thesis" "keywords" "committee")
    for key in "${required_keys[@]}"; do
      if grep -q "${key}:" info.typ 2>/dev/null; then
        ctu_log_ok "  key: $key"
      else
        ctu_log_warn "  missing key: $key in info.typ"
        warnings=$((warnings + 1))
      fi
    done

    # Check: Detect unreplaced {{PLACEHOLDER}} tokens
    if grep -q '{{[A-Z_]\+}}' info.typ 2>/dev/null; then
      ctu_log_warn "Unreplaced placeholders found in info.typ"
      warnings=$((warnings + 1))
    fi
  fi

  echo ""
  echo "--- Format Values ---"

  # Enforce: Font, margins, and line spacing must match CTU Decision 4125
  if [[ -f "info.typ" ]]; then
    if grep -q '"Times New Roman"' info.typ 2>/dev/null; then
      ctu_log_ok "font: Times New Roman"
    else
      ctu_log_warn "font should be Times New Roman per CTU guidelines"
      warnings=$((warnings + 1))
    fi

    if grep -q 'left: 4cm' info.typ 2>/dev/null; then
      ctu_log_ok "margin.left: 4cm"
    else
      ctu_log_error "margin.left should be 4cm per Decision 4125/QĐ-ĐHCT"
      failures=$((failures + 1))
    fi

    if grep -q 'line_spacing: 1.2' info.typ 2>/dev/null; then
      ctu_log_ok "line_spacing: 1.2"
    else
      ctu_log_error "line_spacing should be 1.2"
      failures=$((failures + 1))
    fi
  fi

  echo ""
  echo "--- Font Availability ---"
  # Check: Times New Roman installed via fontconfig
  if command -v fc-list &>/dev/null && fc-list 2>/dev/null | grep -qi "times new roman"; then
    ctu_log_ok "Times New Roman font installed"
  else
    ctu_log_warn "Times New Roman font not found. Typst may use fallback."
    warnings=$((warnings + 1))
  fi

  echo ""
  echo "--- Bibliography ---"
  local bib_file="backmatter/bibliography.bib"
  if [[ -f "$bib_file" ]]; then
    ctu_log_ok "bibliography.bib exists"
    if [[ -s "$bib_file" ]]; then
      local entry_count
      entry_count=$(grep -c '^@' "$bib_file" 2>/dev/null || echo 0)
      ctu_log_ok "  entries: $entry_count"
    else
      ctu_log_warn "bibliography.bib is empty"
      warnings=$((warnings + 1))
    fi
  else
    ctu_log_error "bibliography.bib missing"
    if [[ "$fix_mode" == "true" ]]; then
      # Fix: Create placeholder bibliography with --fix
      mkdir -p backmatter
      echo "@article{example, author={Author}, title={Title}, journal={Journal}, year={2026}}" > "$bib_file"
      ctu_log_warn "  created bibliography.bib"
    fi
    failures=$((failures + 1))
  fi

  echo ""
  echo "--- Include Resolution ---"
  if [[ -f "main.typ" ]]; then
    # Check: Verify all #include targets in main.typ exist on disk
    while IFS= read -r line; do
      local inc
      inc=$(echo "$line" | grep -oP '#include\s+"\K[^"]+' || true)
      if [[ -n "$inc" ]]; then
        if [[ -f "$inc" ]]; then
          ctu_log_ok "  include: $inc"
        else
          ctu_log_warn "  missing include target: $inc"
          warnings=$((warnings + 1))
        fi
      fi
    done < <(grep '#include' main.typ 2>/dev/null || true)
  fi

  echo ""
  echo "=============================="
  if [[ $failures -gt 0 ]]; then
    ctu_log_error "$failures validation failure(s), $warnings warning(s)"
    return 4
  else
    ctu_log_ok "All checks passed ($warnings warnings)."
    return 0
  fi
}

if [[ "${COMMAND:-}" == "validate" ]]; then
  ctu_validate "${COMMAND_ARGS[@]}"
fi
