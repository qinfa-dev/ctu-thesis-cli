#!/usr/bin/env bash
# chapter — manage thesis chapters

ctu_help_chapter() {
  echo "Usage: ctu-thesis chapter <add|remove|list|move> [ARGS]"
  echo ""
  echo "Manage chapters in your thesis project."
  echo ""
  echo "Subcommands:"
  echo "  add TITLE [--after=N|--before=N]   Add a new chapter"
  echo "  remove N [--force] [--renumber]    Remove chapter N"
  echo "  list                                List all chapters"
  echo "  move N --to=M                       Reorder: move chapter N to position M"
  echo ""
  echo "Examples:"
  echo "  ctu-thesis chapter add 'System Design'"
  echo "  ctu-thesis chapter add 'Results' --after=1"
  echo "  ctu-thesis chapter remove 3 --force"
  echo "  ctu-thesis chapter list"
}

# Count: Return number of chapter includes in main.typ
_ctu_chapter_count() {
  grep -c '#include "chapters/chapter[0-9]*\.typ"' main.typ 2>/dev/null || echo 0
}

# Renumber: Reassign sequential chapter numbers after insert/remove/reorder
_ctu_chapter_renumber() {
  local main_typ="main.typ"

  # Collect: Gather existing chapter numbers in include-line order
  local old_numbers=()
  while IFS= read -r line; do
    local num
    num=$(echo "$line" | grep -oP 'chapter\K[0-9]+(?=\.typ)' || true)
    [[ -n "$num" ]] && old_numbers+=("$num")
  done < <(grep '#include "chapters/chapter[0-9]*\.typ"' "$main_typ" || true)

  local i=1
  for old in "${old_numbers[@]}"; do
    local new
    new=$(printf "%02d" "$i")
    ctu_log_debug "Renumber: chapter${old} -> chapter${new}"
    if [[ "$(uname)" == "Darwin" ]]; then
      sed -i '' "s|#include \"chapters/chapter${old}\.typ\"|#include \"chapters/chapter${new}.typ\"|g" "$main_typ"
    else
      sed -i "s|#include \"chapters/chapter${old}\.typ\"|#include \"chapters/chapter${new}.typ\"|g" "$main_typ"
    fi
    i=$((i + 1))
  done
}

# Dispatch: Route chapter subcommand (add/remove/list/move) to handler
ctu_chapter() {
  local root
  if ! root=$(ctu_find_project_root); then
    ctu_log_error "Not in a thesis project directory."
    return 1
  fi
  cd "$root" || return 1

  local sub="${1:-}"
  shift 2>/dev/null || true

  case "$sub" in
    add)
      # Parse: Chapter add flags and title
      local title="${1:-}"
      shift 2>/dev/null || true
      local after="" before=""
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --after) after="$2"; shift 2 ;;
          --before) before="$2"; shift 2 ;;
          *) shift ;;
        esac
      done

      if [[ -z "$title" ]]; then
        ctu_log_error "Usage: chapter add TITLE [--after=N] [--before=N]"
        return 1
      fi

      # Compute: Derive new chapter number from existing count or --after/--before
      local count
      count=$(grep -c '#include "chapters/chapter[0-9]*\.typ"' main.typ 2>/dev/null || echo 0)
      local new_num
      new_num=$((count + 1))

      if [[ -n "$after" ]]; then
        new_num=$((after + 1))
      elif [[ -n "$before" ]]; then
        new_num="$before"
      fi

      # Format: Zero-pad new chapter number for filename
      local padded
      padded=$(printf "%02d" "$new_num")
      local filename="chapters/chapter${padded}.typ"

      # Create: Write new chapter Typst file with title heading
      cat > "$filename" << TYPEOF
= Chapter ${new_num}: ${title}

[Content for Chapter ${new_num}: ${title}]
TYPEOF
      ctu_log_ok "Created: $filename"

      # Add: Insert include line in main.typ marker region (or append if missing)
      local include_line="#include \"chapters/chapter${padded}.typ\""
      if grep -q "// -- CTU-THESIS-CHAPTERS-START --" main.typ 2>/dev/null; then
        ctu_marker_insert main.typ \
          "// -- CTU-THESIS-CHAPTERS-START --" \
          "// -- CTU-THESIS-CHAPTERS-END --" \
          "$include_line"
      else
        echo "$include_line" >> main.typ
      fi

      if [[ -n "$after" || -n "$before" ]]; then
        # Renumber: Re-sequence all chapters when inserting at specific position
        _ctu_chapter_renumber
      fi

      ctu_log_ok "Chapter $new_num added."
      ;;

    remove)
      # Parse: Chapter remove flags
      local num="${1:-}"
      shift 2>/dev/null || true
      local force=false
      local renumber=false
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --force) force=true; shift ;;
          --renumber) renumber=true; shift ;;
          *) shift ;;
        esac
      done

      if [[ -z "$num" ]]; then
        ctu_log_error "Usage: chapter remove N [--force] [--renumber]"
        return 1
      fi

      # Guard: Prevent removal of the only remaining chapter
      local count
      count=$(grep -c '#include "chapters/chapter[0-9]*\.typ"' main.typ 2>/dev/null || echo 0)
      if [[ "$count" -le 1 ]] && [[ "$force" != "true" ]]; then
        ctu_log_error "Cannot remove the only remaining chapter."
        return 1
      fi

      local padded
      padded=$(printf "%02d" "$num")
      local filename="chapters/chapter${padded}.typ"

      # Check: Verify chapter file exists
      if [[ ! -f "$filename" ]] && [[ "$force" != "true" ]]; then
        ctu_log_error "Chapter $num not found: $filename"
        return 1
      fi

      # Confirm: Prompt for confirmation unless --force is set
      if [[ "$force" != "true" ]]; then
        read -r -p "Remove chapter $num? (y/N): " confirm
        [[ "$confirm" != "y" ]] && { ctu_log_info "Cancelled."; return 5; }
      fi

      # Remove: Delete chapter file and its include line from main.typ
      rm -f "$filename"
      ctu_log_ok "Deleted: $filename"

      if [[ "$(uname)" == "Darwin" ]]; then
        sed -i '' "/chapter${padded}.typ/d" main.typ
      else
        sed -i "/chapter${padded}.typ/d" main.typ
      fi

      if [[ "$renumber" == "true" ]]; then
        # Renumber: Re-sequence remaining chapters after removal
        _ctu_chapter_renumber
      fi
      ;;

    list)
      # List: Print all chapters with title and filename
      local i=0
      while IFS= read -r line; do
        i=$((i + 1))
        local fn
        fn=$(echo "$line" | grep -oP 'chapters/chapter[0-9]+\.typ' || true)
        local title=""
        if [[ -f "$fn" ]]; then
          title=$(grep -m1 '^= ' "$fn" 2>/dev/null | sed 's/^= *//' || echo "(no title)")
        else
          title="(file missing)"
        fi
        echo "${i}. ${title} (${fn})"
      done < <(grep '#include "chapters/chapter[0-9]*\.typ"' main.typ 2>/dev/null || true)
      if [[ $i -eq 0 ]]; then
        ctu_log_info "No chapters found."
      fi
      ;;

    move)
      # Parse: Chapter move flags
      local num="${1:-}"
      shift 2>/dev/null || true
      local to=""
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --to) to="$2"; shift 2 ;;
          *) shift ;;
        esac
      done
      if [[ -z "$num" || -z "$to" ]]; then
        ctu_log_info "Move requires: chapter move N --to=M"
        return 1
      fi
      # TODO(qingfa, 2026-05-25): Implement chapter reorder logic — TASK
      ctu_log_info "Move not yet fully implemented in v1.0."
      ;;

    *)
      ctu_help_chapter
      return 1
      ;;
  esac
}

if [[ "${COMMAND:-}" == "chapter" ]]; then
  ctu_chapter "${COMMAND_ARGS[@]}"
fi
