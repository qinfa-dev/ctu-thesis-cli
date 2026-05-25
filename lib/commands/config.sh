#!/usr/bin/env bash
# config — manage user defaults in ~/.ctu-thesis/config

ctu_help_config() {
  echo "Usage: ctu-thesis config <get|set|list|unset> [KEY] [VALUE]"
  echo ""
  echo "Manage default values used by init and other commands."
  echo "Config file: ~/.ctu-thesis/config"
  echo ""
  echo "Subcommands:"
  echo "  set KEY VALUE   Set a config value"
  echo "  get KEY         Get a config value"
  echo "  list            List all config values"
  echo "  unset KEY       Remove a config value"
  echo ""
  echo "Common keys:"
  echo "  student.name, student.id, student.class"
  echo "  advisor.name, advisor.title"
  echo "  lang, type"
  echo ""
  echo "Examples:"
  echo "  ctu-thesis config set student.name 'Nguyen Van A'"
  echo "  ctu-thesis config set lang vi"
  echo "  ctu-thesis config list"
}

ctu_config_cmd() {
  local sub="${1:-}"
  case "$sub" in
    set)
      local key="${2:-}"
      local value="${3:-}"
      if [[ -z "$key" || -z "$value" ]]; then
        ctu_log_error "Usage: config set KEY VALUE"
        return 1
      fi
      shift 2
      ctu_config_set "$key" "${*}"
      ctu_log_ok "Set $key"
      ;;
    get)
      local key="${2:-}"
      if [[ -z "$key" ]]; then
        ctu_log_error "Usage: config get KEY"
        return 1
      fi
      if ctu_config_get "$key"; then
        return 0
      else
        ctu_log_warn "No value for $key"
        return 1
      fi
      ;;
    list)
      ctu_config_list || { ctu_log_info "No config values set."; return 1; }
      ;;
    unset)
      local key="${2:-}"
      if [[ -z "$key" ]]; then
        ctu_log_error "Usage: config unset KEY"
        return 1
      fi
      ctu_config_unset "$key" && ctu_log_ok "Unset $key"
      ;;
    *)
      ctu_help_config
      return 1
      ;;
  esac
}

if [[ "${COMMAND:-}" == "config" ]]; then
  ctu_config_cmd "${COMMAND_ARGS[@]}"
fi
