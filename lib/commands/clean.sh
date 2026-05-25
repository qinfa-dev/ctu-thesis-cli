#!/usr/bin/env bash
# clean — remove build artifacts

ctu_help_clean() {
  echo "Usage: ctu-thesis clean [--all]"
  echo ""
  echo "Remove build artifacts from the project directory."
  echo "  *.pdf, *.tmp, *.bak"
  echo ""
  echo "Options:"
  echo "  --all    Also remove .ctu-thesisrc"
}

# Remove: Delete build artifacts (pdf, tmp, bak) from project root
ctu_clean() {
  local all=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --all) all=true; shift ;;
      *) shift ;;
    esac
  done

  # Find: Locate project root or clean current directory as fallback
  local root
  if ! root=$(ctu_find_project_root); then
    ctu_log_warn "Not in a thesis project directory; cleaning current directory."
    root="$PWD"
  fi

  local cleaned=0
  # Remove: Delete all pdf, tmp, bak files in root directory
  for ext in pdf tmp bak; do
    while IFS= read -r -d $'\0' f; do
      rm -f "$f"
      ctu_log_ok "Removed: $(basename "$f")"
      cleaned=$((cleaned + 1))
    done < <(find "$root" -maxdepth 1 -name "*.${ext}" -type f -print0 2>/dev/null || true)
  done

  if [[ "$all" == "true" ]] && [[ -f "$root/.ctu-thesisrc" ]]; then
    # Remove: Also delete .ctu-thesisrc when --all flag is set
    rm -f "$root/.ctu-thesisrc"
    ctu_log_ok "Removed: .ctu-thesisrc"
    cleaned=$((cleaned + 1))
  fi

  if [[ $cleaned -eq 0 ]]; then
    ctu_log_info "Nothing to clean."
  fi
}

if [[ "${COMMAND:-}" == "clean" ]]; then
  ctu_clean "${COMMAND_ARGS[@]}"
fi
