#!/usr/bin/env bash

# shellcheck disable=SC2155

# Initialize: Path constants for CTU runtime — config, templates, cache
[ -z "${CTU_VERSION}" ] && CTU_VERSION="1.0.0"
CTU_HOME="${CTU_HOME:-$HOME/.ctu-thesis}"
CTU_CONFIG="${CTU_CONFIG:-$CTU_HOME/config}"
CTU_TEMPLATES_DIR="${CTU_TEMPLATES_DIR:-$CTU_HOME/templates}"
CTU_CACHE_DIR="${CTU_CACHE_DIR:-$CTU_HOME/cache}"

export CTU_VERSION CTU_HOME CTU_CONFIG CTU_TEMPLATES_DIR CTU_CACHE_DIR

# Check: Whether terminal supports ANSI color output (NO_COLOR opt-out)
_ctu_use_color() {
  [[ -z "${NO_COLOR:-}" ]] && [[ -t 1 || -t 2 ]]
}

# Format: Wrap text in ANSI color codes for terminal display
_ctu_color() {
  local code="$1"; shift
  if _ctu_use_color; then
    printf "\033[%sm%s\033[0m" "$code" "$*"
  else
    printf "%s" "$*"
  fi
}

# Log: Print plain message to stdout
ctu_log()        { printf "%s\n" "$*"; }

# Log: Print cyan [info] prefixed message to stdout
ctu_log_info()   { printf "%s %s\n" "$(_ctu_color "36" "[info]")" "$*"; }

# Log: Print green [ ok ] prefixed message to stdout
ctu_log_ok()     { printf "%s %s\n" "$(_ctu_color "32" "[ ok ]")" "$*"; }

# Log: Print yellow [warn] prefixed message to stderr
ctu_log_warn()   { printf "%s %s\n" "$(_ctu_color "33" "[warn]")" "$*" >&2; }

# Log: Print red [FAIL] prefixed message to stderr
ctu_log_error()  { printf "%s %s\n" "$(_ctu_color "31" "[FAIL]")" "$*" >&2; }

# Log: Print blue [dbug] message to stderr only when CTU_VERBOSE is true
ctu_log_debug()  {
  if [[ "${CTU_VERBOSE:-false}" == "true" ]]; then
    printf "%s %s\n" "$(_ctu_color "34" "[dbug]")" "$*" >&2;
  fi
}

# Guard: Log error and exit with given code — terminates on fatal state
ctu_die() {
  local code="$1"; shift
  ctu_log_error "$@"
  exit "$code"
}

# Detect: Platform-compatible sed -i flag (macOS uses '' arg, Linux uses no arg)
_ctu_sed_i() {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    sed -i '' "$@"
  else
    sed -i "$@"
  fi
}

# Read: Get value for key from ini-style config file; returns 1 if key missing
ctu_config_get() {
  local key="$1"
  [[ -f "$CTU_CONFIG" ]] || return 1
  local val
  val="$(grep -E "^${key}=" "$CTU_CONFIG" 2>/dev/null | tail -1 | cut -d= -f2-)"
  if [[ -n "$val" ]]; then
    printf "%s" "$val"
    return 0
  fi
  return 1
}

# Assign: Upsert key=value in config file — replaces existing or appends new
ctu_config_set() {
  local key="$1" value="$2"
  mkdir -p "$(dirname "$CTU_CONFIG")"
  if grep -qE "^${key}=" "$CTU_CONFIG" 2>/dev/null; then
    _ctu_sed_i "s|^${key}=.*|${key}=${value}|" "$CTU_CONFIG"
  else
    printf "%s=%s\n" "$key" "$value" >> "$CTU_CONFIG"
  fi
}

# Remove: Delete key=value line from config file
ctu_config_unset() {
  local key="$1"
  [[ -f "$CTU_CONFIG" ]] || return 0
  _ctu_sed_i "/^${key}=/d" "$CTU_CONFIG"
}

# List: Print all non-empty, non-comment config lines to stdout
ctu_config_list() {
  [[ -f "$CTU_CONFIG" ]] || return 0
  grep -vE '^\s*(#|$)' "$CTU_CONFIG" 2>/dev/null || true
}

# Check: Verify required command exists on PATH
ctu_check_cmd() {
  command -v "$1" &>/dev/null
}

# Get: Retrieve command version string via --version flag (or custom flag)
ctu_get_cmd_version() {
  local cmd="$1" flag="${2:---version}"
  "$cmd" "$flag" 2>&1 | head -1
}

# Find: Walk up directory tree for main.typ + info.typ sentinel files
ctu_find_project_root() {
  local dir="${1:-$PWD}"
  dir="$(cd "$dir" 2>/dev/null && pwd)" || return 1
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/main.typ" ]] && [[ -f "$dir/info.typ" ]]; then
      printf "%s" "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

# -- Marker region helpers ---------------------------------------------------
# Add: Insert content between start/end marker lines in a file; create file if missing
ctu_marker_insert() {
  local file="$1" start_marker="$2" end_marker="$3" content="$4"
  local dir
  dir="$(dirname "$file")"
  mkdir -p "$dir"

  if [[ ! -f "$file" ]]; then
    printf "%s\n%s\n%s\n" "$start_marker" "$content" "$end_marker" > "$file"
    return 0
  fi

  if grep -qF "$start_marker" "$file" && grep -qF "$end_marker" "$file"; then
    _ctu_sed_i "/^$(printf "%s" "$start_marker" | sed 's/[\/&]/\\&/g')$/,/^$(printf "%s" "$end_marker" | sed 's/[\/&]/\\&/g')$/{
      /^$(printf "%s" "$start_marker" | sed 's/[\/&]/\\&/g')$/!{/^$(printf "%s" "$end_marker" | sed 's/[\/&]/\\&/g')$/!d}
    }" "$file"
    _ctu_sed_i "/^$(printf "%s" "$end_marker" | sed 's/[\/&]/\\&/g')$/i\\
$content
" "$file"
  else
    printf "\n%s\n%s\n%s\n" "$start_marker" "$content" "$end_marker" >> "$file"
  fi
}

# Read: Extract content between marker lines from a file
ctu_marker_read() {
  local file="$1" start_marker="$2" end_marker="$3"
  [[ -f "$file" ]] || return 1
  awk "/^${start_marker}$/,/^${end_marker}$/" "$file" | sed '1d;$d'
}

# Replace: Substitute {{PLACEHOLDER}} tokens with values in target file
ctu_placeholders_replace() {
  local file="$1"; shift
  [[ -f "$file" ]] || return 1
  local args=("$@")
  local i
  for (( i=0; i<${#args[@]}; i+=2 )); do
    local placeholder="${args[i]}"
    local value="${args[i+1]:-}"
    _ctu_sed_i "s|{{${placeholder}}}|${value}|g" "$file"
  done
}

# Format: Zero-pad chapter number to specified width (default 2)
ctu_chapter_pad() {
  local num="$1" padding="${2:-2}"
  printf "%0${padding}d" "$num"
}
