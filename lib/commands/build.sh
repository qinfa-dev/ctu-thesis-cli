#!/usr/bin/env bash
# build — compile the thesis project to PDF

ctu_help_build() {
  echo "Usage: ctu-thesis build [OPTIONS]"
  echo ""
  echo "Compile the thesis to PDF using typst."
  echo "Must be run from within a thesis project directory."
  echo ""
  echo "Options:"
  echo "  --watch         Watch for changes and auto-recompile"
  echo "  --draft         Skip bibliography for faster compilation"
  echo "  --output FILE   Override output filename"
  echo ""
  echo "Examples:"
  echo "  ctu-thesis build"
  echo "  ctu-thesis build --watch"
  echo "  ctu-thesis build --draft"
}

# Build: Compile thesis project to PDF using typst with optional watch and draft modes
ctu_build() {
  local watch_mode=false
  local draft_mode=false
  local output_file=""

  # Parse: Read build subcommand flags
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --watch) watch_mode=true; shift ;;
      --draft) draft_mode=true; shift ;;
      --output) output_file="$2"; shift 2 ;;
      *) shift ;;
    esac
  done

  # Find: Locate project root via main.typ + info.typ sentinels
  local root
  if ! root=$(ctu_find_project_root); then
    ctu_log_error "Not in a thesis project directory (main.typ + info.typ not found)."
    return 1
  fi

  cd "$root" || return 1

  # Check: Typst compiler must be installed
  if ! command -v typst &>/dev/null; then
    ctu_log_error "typst not found. Install: https://github.com/typst/typst/releases"
    return 2
  fi

  # Detect: Derive output filename from primary_lang in info.typ
  if [[ -z "$output_file" ]]; then
    local lang
    lang=$(grep -oP 'primary_lang:\s*"\K[^"]+' info.typ 2>/dev/null || echo "en")
    if [[ "$lang" == "vi" ]]; then
      output_file="luan-van-vi.pdf"
    else
      output_file="thesis-en.pdf"
    fi
  fi

  # Defer: In draft mode, comment out bibliography for faster compilation,
  #         restore on EXIT via trap
  local tmp_main=""
  if [[ "$draft_mode" == "true" ]]; then
    tmp_main="${root}/main.typ.ctu-draft-$$"
    cp main.typ "$tmp_main"
    if [[ "$(uname)" == "Darwin" ]]; then
      sed -i '' 's/^#bibliography(/\/\/ #bibliography(/' main.typ 2>/dev/null || true
    else
      sed -i 's/^#bibliography(/\/\/ #bibliography(/' main.typ 2>/dev/null || true
    fi
    trap '[[ -f "$tmp_main" ]] && mv "$tmp_main" main.typ 2>/dev/null; ctu_log_info "Draft mode cleaned up."' EXIT
    ctu_log_info "Draft mode: bibliography skipped."
  fi

  # Compile: Run typst in watch or single-shot mode
  if [[ "$watch_mode" == "true" ]]; then
    ctu_log_info "Watching for changes... (Ctrl+C to stop)"
    typst watch main.typ "$output_file"
  else
    ctu_log_info "Compiling..."
    if typst compile main.typ "$output_file"; then
      ctu_log_ok "Generated: $output_file"
    else
      ctu_log_error "Compilation failed."
      return 1
    fi
  fi

  # Recover: Restore original main.typ from draft backup and clear trap on success
  if [[ "$draft_mode" == "true" ]] && [[ -n "$tmp_main" ]]; then
    trap - EXIT
    mv "$tmp_main" main.typ
    ctu_log_info "Draft mode cleaned up."
  fi
}

# Guard: only auto-execute when this file is sourced as the target command
# (not when sourced by `help` for usage display)
if [[ "${COMMAND:-}" == "build" ]]; then
  ctu_build "${COMMAND_ARGS[@]}"
fi
