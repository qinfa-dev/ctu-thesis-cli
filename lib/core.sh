#!/usr/bin/env bash
# ctu-thesis core library — shared functions for all commands
#
# shellcheck disable=SC2155

# -- Constants ---------------------------------------------------------------
[ -z "${CTU_VERSION}" ] && CTU_VERSION="1.0.0"
CTU_HOME="${CTU_HOME:-$HOME/.ctu-thesis}"
CTU_CONFIG="${CTU_CONFIG:-$CTU_HOME/config}"
CTU_TEMPLATES_DIR="${CTU_TEMPLATES_DIR:-$CTU_HOME/templates}"
CTU_CACHE_DIR="${CTU_CACHE_DIR:-$CTU_HOME/cache}"

export CTU_VERSION CTU_HOME CTU_CONFIG CTU_TEMPLATES_DIR CTU_CACHE_DIR

# -- Color helpers -----------------------------------------------------------
_ctu_use_color() {
  [[ -z "${NO_COLOR:-}" ]] && [[ -t 1 || -t 2 ]]
}

_ctu_color() {
  local code="$1"; shift
  if _ctu_use_color; then
    printf "\033[%sm%s\033[0m" "$code" "$*"
  else
    printf "%s" "$*"
  fi
}

# -- Logging -----------------------------------------------------------------
ctu_log()        { printf "%s\n" "$*"; }

ctu_log_info()   { printf "%s %s\n" "$(_ctu_color "36" "[info]")" "$*"; }

ctu_log_ok()     { printf "%s %s\n" "$(_ctu_color "32" "[ ok ]")" "$*"; }

ctu_log_warn()   { printf "%s %s\n" "$(_ctu_color "33" "[warn]")" "$*" >&2; }

ctu_log_error()  { printf "%s %s\n" "$(_ctu_color "31" "[FAIL]")" "$*" >&2; }

ctu_log_debug()  {
  if [[ "${CTU_VERBOSE:-false}" == "true" ]]; then
    printf "%s %s\n" "$(_ctu_color "34" "[dbug]")" "$*" >&2;
  fi
}

ctu_die() {
  local code="$1"; shift
  ctu_log_error "$@"
  exit "$code"
}

# -- Config I/O (ini-style key=value) ----------------------------------------
_ctu_sed_i() {
  # Use -i'' on macOS, -i on Linux
  if [[ "$(uname -s)" == "Darwin" ]]; then
    sed -i '' "$@"
  else
    sed -i "$@"
  fi
}

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

ctu_config_set() {
  local key="$1" value="$2"
  mkdir -p "$(dirname "$CTU_CONFIG")"
  if grep -qE "^${key}=" "$CTU_CONFIG" 2>/dev/null; then
    _ctu_sed_i "s|^${key}=.*|${key}=${value}|" "$CTU_CONFIG"
  else
    printf "%s=%s\n" "$key" "$value" >> "$CTU_CONFIG"
  fi
}

ctu_config_unset() {
  local key="$1"
  [[ -f "$CTU_CONFIG" ]] || return 0
  _ctu_sed_i "/^${key}=/d" "$CTU_CONFIG"
}

ctu_config_list() {
  [[ -f "$CTU_CONFIG" ]] || return 0
  grep -vE '^\s*(#|$)' "$CTU_CONFIG" 2>/dev/null || true
}

# -- Dependency checks -------------------------------------------------------
ctu_check_cmd() {
  command -v "$1" &>/dev/null
}

ctu_get_cmd_version() {
  local cmd="$1" flag="${2:---version}"
  "$cmd" "$flag" 2>&1 | head -1
}

# -- Project root finder -----------------------------------------------------
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

ctu_marker_read() {
  local file="$1" start_marker="$2" end_marker="$3"
  [[ -f "$file" ]] || return 1
  awk "/^${start_marker}$/,/^${end_marker}$/" "$file" | sed '1d;$d'
}

# -- Placeholder substitution -------------------------------------------------
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

# -- Chapter padding ---------------------------------------------------------
ctu_chapter_pad() {
  local num="$1" padding="${2:-2}"
  printf "%0${padding}d" "$num"
}
