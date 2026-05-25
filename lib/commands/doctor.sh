#!/usr/bin/env bash
# doctor — diagnose the user's environment

CLR_GREEN='\033[0;32m'
CLR_RED='\033[0;31m'
CLR_YELLOW='\033[0;33m'
CLR_RESET='\033[0m'

ctu_help_doctor() {
  echo "Usage: ctu-thesis doctor [--json]"
  echo ""
  echo "Diagnose your environment for thesis development."
  echo "Checks: bash, typst, git, curl, Times New Roman font,"
  echo "        internet, project validity, template cache."
  echo ""
  echo "Options:"
  echo "  --json    Output machine-readable JSON (one object per line)"
  echo ""
  echo "Exit codes: 0=all OK, 2=some checks failed"
}

# Log: Output doctor check status in human-readable or JSON format
_ctu_doctor_status() {
  local check="$1"
  local status="$2"
  local detail="${3:-}"
  local json="${4:-false}"

  if [[ "$json" == "true" ]]; then
    # Serialize: Build JSON object for machine-readable output
    local msg="{\"check\":\"$check\",\"status\":\"$status\""
    [[ -n "$detail" ]] && msg="$msg,\"detail\":\"$detail\""
    msg="$msg}"
    echo "$msg"
  else
    case "$status" in
      ok)   echo -e "  ${CLR_GREEN}[OK]${CLR_RESET} $check: $detail" ;;
      warn) echo -e "  ${CLR_YELLOW}[WARN]${CLR_RESET} $check: $detail" ;;
      fail) echo -e "  ${CLR_RED}[FAIL]${CLR_RESET} $check: $detail" ;;
    esac
  fi
}

# Diagnose: Run all environment checks and report status for thesis development
ctu_doctor() {
  local json_output=false
  local overall_ok=true

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --json) json_output=true; shift ;;
      *) shift ;;
    esac
  done

  if [[ "$json_output" != "true" ]]; then
    echo "ctu-thesis Doctor v${CTU_VERSION}"
    echo "================================"
  fi

  # Check: Bash version must be 4.2+ for associative arrays and mapfile support
  local bash_ver="${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}"
  if [[ "${BASH_VERSINFO[0]}" -ge 4 ]] && [[ "${BASH_VERSINFO[1]}" -ge 2 ]]; then
    _ctu_doctor_status "bash" "ok" "$bash_ver" "$json_output"
  else
    _ctu_doctor_status "bash" "fail" "bash $bash_ver — need 4.2+" "$json_output"
    overall_ok=false
  fi

  # Check: Typst compiler must be installed for PDF compilation
  if command -v typst &>/dev/null; then
    local tv
    tv=$(typst --version 2>&1 | head -1)
    _ctu_doctor_status "typst" "ok" "$tv" "$json_output"
  else
    _ctu_doctor_status "typst" "fail" "typst not found. Install: https://github.com/typst/typst/releases" "$json_output"
    overall_ok=false
  fi

  # Check: Git is optional but useful for version control
  if command -v git &>/dev/null; then
    _ctu_doctor_status "git" "ok" "$(git --version 2>&1 | head -1)" "$json_output"
  else
    _ctu_doctor_status "git" "warn" "git not found (optional)" "$json_output"
  fi

  # Check: Curl is required for update and remote operations
  if command -v curl &>/dev/null; then
    _ctu_doctor_status "curl" "ok" "$(curl --version 2>&1 | head -1)" "$json_output"
  else
    _ctu_doctor_status "curl" "fail" "curl not found. Required for updates." "$json_output"
    overall_ok=false
  fi

  # Check: Times New Roman font — try fc-list, macOS paths, WSL paths, native Windows
  local tnr_found=false
  if command -v fc-list &>/dev/null; then
    if fc-list 2>/dev/null | grep -qi "times new roman"; then
      tnr_found=true
    fi
  fi
  if [[ "$tnr_found" != "true" ]] && [[ "$(uname)" == "Darwin" ]]; then
    if [[ -f "/System/Library/Fonts/Times New Roman.ttf" ]] || [[ -f "/Library/Fonts/Times New Roman.ttf" ]]; then
      tnr_found=true
    fi
  fi
  if [[ "$tnr_found" != "true" ]]; then
    for windir in "/c/Windows/Fonts/times.ttf" "/mnt/c/Windows/Fonts/times.ttf"; do
      [[ -f "$windir" ]] && { tnr_found=true; break; }
    done
  fi
  if [[ "$tnr_found" != "true" ]] && [[ -n "${SystemRoot:-}" ]]; then
    [[ -f "${SystemRoot}/Fonts/times.ttf" ]] && tnr_found=true
  fi
  if [[ "$tnr_found" == "true" ]]; then
    _ctu_doctor_status "font_times_new_roman" "ok" "found" "$json_output"
  else
    local tnr_hint=""
    case "$(uname -s)" in
      Linux)   tnr_hint="Install: apt-get install ttf-mscorefonts-installer" ;;
      Darwin)  tnr_hint="Install via Font Book or MS Office" ;;
      MINGW*|MSYS*|CYGWIN*) tnr_hint="Pre-installed on Windows. Check C:\\Windows\\Fonts\\times.ttf" ;;
      *)       tnr_hint="Install Times New Roman font" ;;
    esac
    _ctu_doctor_status "font_times_new_roman" "warn" "not found. $tnr_hint. Typst will use fallback." "$json_output"
  fi

  # Check: Internet reachability via GitHub (needed for updates)
  if command -v curl &>/dev/null && curl -s --connect-timeout 5 https://github.com >/dev/null 2>&1; then
    _ctu_doctor_status "internet" "ok" "github.com reachable" "$json_output"
  else
    _ctu_doctor_status "internet" "warn" "cannot reach github.com (updates may fail)" "$json_output"
  fi

  # Check: Whether current directory is inside a valid thesis project
  local root
  if root=$(ctu_find_project_root); then
    _ctu_doctor_status "project" "ok" "found at $root" "$json_output"
  else
    _ctu_doctor_status "project" "info" "not in a thesis project directory (run 'ctu-thesis init' to create one)" "$json_output"
  fi

  # Check: Template cache is populated for init command
  if [[ -d "$CTU_TEMPLATES_DIR" ]] && [[ -f "$CTU_TEMPLATES_DIR/main.typ" ]]; then
    _ctu_doctor_status "template_cache" "ok" "populated" "$json_output"
  else
    _ctu_doctor_status "template_cache" "warn" "empty or missing. Run 'ctu-thesis update --templates'" "$json_output"
  fi

  if [[ "$overall_ok" != "true" ]]; then
    exit 2
  fi
}

if [[ "${COMMAND:-}" == "doctor" ]]; then
  ctu_doctor "${COMMAND_ARGS[@]}"
fi
