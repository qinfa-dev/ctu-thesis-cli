#!/usr/bin/env bash
# help — show usage and command reference

ctu_help_help() {
  echo "Usage: ctu-thesis help [COMMAND]"
  echo "Show detailed usage for a command, or list all commands."
}

ctu_help() {
  local topic="${1:-}"

  if [[ -n "$topic" ]]; then
    if [[ "$topic" == "help" ]]; then
      ctu_help_help
      return
    fi
    local cmd_file="$LIB_DIR/commands/${topic}.sh"
    if [[ -f "$cmd_file" ]]; then
      # shellcheck source=/dev/null
      source "$cmd_file"
      local help_fn="ctu_help_${topic}"
      if declare -f "$help_fn" &>/dev/null; then
        "$help_fn"
      else
        echo "No detailed help available for '$topic'."
      fi
    else
      ctu_log_error "Unknown command: $topic"
    fi
    return
  fi

  echo "ctu-thesis v${CTU_VERSION} — CTU Thesis Project Manager"
  echo ""
  echo "Usage: ctu-thesis [GLOBAL FLAGS] COMMAND [ARGS]"
  echo ""
  echo "Global flags:"
  echo "  -v, --verbose    Show debug output"
  echo "  -q, --quiet      Suppress non-error output"
  echo "  -h, --help       Show this help"
  echo "  --version        Show version"
  echo ""
  echo "Commands:"
  echo "  init      Create a new thesis project"
  echo "  build     Compile the thesis to PDF"
  echo "  validate  Check CTU guideline compliance"
  echo "  doctor    Diagnose your environment"
  echo "  clean     Remove build artifacts"
  echo "  config    Manage user defaults"
  echo "  chapter   Add, remove, or list chapters"
  echo "  update    Update CLI and/or templates"
  echo "  help      Show this help or command-specific help"
  echo ""
  echo "Run 'ctu-thesis help COMMAND' for detailed usage."
}

# Auto-execute when sourced from entrypoint
if [[ "${COMMAND:-}" == "help" ]]; then
  ctu_help "${COMMAND_ARGS[@]}"
fi
