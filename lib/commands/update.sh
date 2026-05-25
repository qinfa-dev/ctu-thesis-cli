#!/usr/bin/env bash
# update — update CLI and/or cached templates

ctu_help_update() {
  echo "Usage: ctu-thesis update [--cli] [--templates]"
  echo ""
  echo "Update the CLI tool and/or cached templates."
  echo ""
  echo "Options:"
  echo "  --cli         Reinstall the CLI from GitHub"
  echo "  --templates   Refresh cached template files"
  echo ""
  echo "If no option is given, both are updated."
}

ctu_update() {
  local update_cli=false
  local update_templates=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --cli) update_cli=true; shift ;;
      --templates) update_templates=true; shift ;;
      *) shift ;;
    esac
  done

  if [[ "$update_cli" != "true" && "$update_templates" != "true" ]]; then
    update_cli=true
    update_templates=true
  fi

  if [[ "$update_cli" == "true" ]]; then
    ctu_log_info "Updating CLI..."
    if [[ -f "$HOME/.ctu-thesis/bin/ctu-thesis" ]]; then
      local backup_dir="$HOME/.ctu-thesis-backup-$(date +%Y%m%d-%H%M%S)"
      cp -r "$HOME/.ctu-thesis" "$backup_dir" 2>/dev/null || true
      ctu_log_info "Backed up to: $backup_dir"
    fi
    ctu_log_warn "CLI update requires install.sh. Run: curl -fsSL <install-url> | bash"
  fi

  if [[ "$update_templates" == "true" ]]; then
    ctu_log_info "Updating template cache..."
    if [[ -d "$CTU_TEMPLATES_DIR" ]]; then
      rm -rf "$CTU_TEMPLATES_DIR"
      ctu_log_ok "Cleared old template cache"
    fi
    if [[ -d "$LIB_DIR/../templates" ]] && [[ -f "$LIB_DIR/../templates/main.typ" ]]; then
      cp -r "$LIB_DIR/../templates" "$CTU_TEMPLATES_DIR"
      ctu_log_ok "Templates refreshed from local install"
    else
      ctu_log_warn "Cannot find local templates. Please reinstall."
    fi
  fi

  ctu_log_ok "Update complete."
}

ctu_update "${COMMAND_ARGS[@]}"
