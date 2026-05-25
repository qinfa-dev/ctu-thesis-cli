#!/usr/bin/env bash
# init — scaffold a new CTU thesis project

ctu_help_init() {
  echo "Usage: ctu-thesis init [PATH] [OPTIONS]"
  echo ""
  echo "Create a new thesis project with CTU-compliant template."
  echo ""
  echo "Options:"
  echo "  --type TYPE              Thesis type: bachelor (default)"
  echo "  --lang LANG              Language: en, vi (default: en)"
  echo "  --title TITLE            Thesis title"
  echo "  --student NAME           Your full name"
  echo "  --id ID                  Student ID (e.g., B2026001)"
  echo "  --class CLASS            Class (e.g., DI2296A1)"
  echo "  --advisor NAME           Advisor name with title (e.g., TS. Tran Thi B)"
  echo "  --advisor-title TITLE    Advisor academic title (e.g., TS., Dr.)"
  echo "  --major TEXT             Major (English)"
  echo "  --program TEXT           Program (English)"
  echo "  --location TEXT          Location (default: Can Tho)"
  echo "  --non-interactive        Skip prompts, use defaults for missing values"
  echo "  --force                  Overwrite existing directory"
  echo ""
  echo "Examples:"
  echo "  ctu-thesis init my-thesis --lang=vi --title='He Thong TMĐT'"
  echo "  ctu-thesis init . --lang=en --non-interactive"
}

# -- Default value maps for auto-generated VI counterparts --
declare -A _VI_MAJORS=(
  ["INFORMATION TECHNOLOGY"]="CÔNG NGHỆ THÔNG TIN"
  ["SOFTWARE ENGINEERING"]="KỸ THUẬT PHẦN MỀM"
  ["COMPUTER SCIENCE"]="KHOA HỌC MÁY TÍNH"
)
declare -A _VI_PROGRAMS=(
  ["High-Quality Program"]="Chất lượng cao"
  ["Standard Program"]="Đại trà"
)
declare -A _VI_DEGREES=(
  ["BACHELOR OF ENGINEERING"]="KỸ SƯ"
)

_ctu_init_vi_val() {
  local key="$1"
  local en_val="$2"
  case "$key" in
    major) echo "${_VI_MAJORS[$en_val]:-$en_val}" ;;
    program) echo "${_VI_PROGRAMS[$en_val]:-$en_val}" ;;
    degree) echo "${_VI_DEGREES[$en_val]:-$en_val}" ;;
    *) echo "$en_val" ;;
  esac
}

ctu_init() {
  local project_path=""
  local thesis_type="bachelor"
  local lang="en"
  local title=""
  local student_name=""
  local student_id=""
  local student_class=""
  local advisor_name=""
  local advisor_title=""
  local major="INFORMATION TECHNOLOGY"
  local program="High-Quality Program"
  local location="Can Tho"
  local non_interactive=false
  local force=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --type=*) thesis_type="${1#*=}"; shift ;;
      --type) thesis_type="$2"; shift 2 ;;
      --lang=*) lang="${1#*=}"; shift ;;
      --lang) lang="$2"; shift 2 ;;
      --title=*) title="${1#*=}"; shift ;;
      --title) title="$2"; shift 2 ;;
      --student=*) student_name="${1#*=}"; shift ;;
      --student) student_name="$2"; shift 2 ;;
      --id=*) student_id="${1#*=}"; shift ;;
      --id) student_id="$2"; shift 2 ;;
      --class=*) student_class="${1#*=}"; shift ;;
      --class) student_class="$2"; shift 2 ;;
      --advisor=*) advisor_name="${1#*=}"; shift ;;
      --advisor) advisor_name="$2"; shift 2 ;;
      --advisor-title=*) advisor_title="${1#*=}"; shift ;;
      --advisor-title) advisor_title="$2"; shift 2 ;;
      --major=*) major="${1#*=}"; shift ;;
      --major) major="$2"; shift 2 ;;
      --program=*) program="${1#*=}"; shift ;;
      --program) program="$2"; shift 2 ;;
      --location=*) location="${1#*=}"; shift ;;
      --location) location="$2"; shift 2 ;;
      --non-interactive) non_interactive=true; shift ;;
      --force) force=true; shift ;;
      -*)
        ctu_log_error "Unknown flag: $1"
        return 1
        ;;
      *)
        [[ -z "$project_path" ]] && { project_path="$1"; shift; } || { ctu_log_error "Unexpected argument: $1"; return 1; }
        ;;
    esac
  done

  [[ -z "$project_path" ]] && project_path="ctu-thesis"

  # Validate language
  if [[ "$lang" != "en" && "$lang" != "vi" ]]; then
    ctu_log_error "Unsupported language '$lang'. Valid options: en, vi."
    return 1
  fi

  # Validate type
  if [[ "$thesis_type" != "bachelor" ]]; then
    ctu_log_error "Unsupported type '$thesis_type'. Only 'bachelor' is supported in v1.0."
    return 1
  fi

  # Resolve absolute path
  local abs_path
  abs_path="$(cd "$(dirname "$project_path")" 2>/dev/null && pwd)/$(basename "$project_path")" || abs_path="$PWD/$project_path"

  # Check for existing directory
  if [[ -d "$abs_path" ]]; then
    if [[ "$force" != "true" ]]; then
      ctu_log_error "'$project_path' already exists. Use --force to overwrite."
      return 1
    fi
    rm -rf "$abs_path"
  fi

  # Interactive prompts for missing values
  if [[ "$non_interactive" != "true" ]]; then
    [[ -z "$student_name" ]] && { student_name=$(ctu_config_get student.name 2>/dev/null || true); [[ -z "$student_name" ]] && read -r -p "Your full name: " student_name; }
    [[ -z "$student_id" ]] && { student_id=$(ctu_config_get student.id 2>/dev/null || true); [[ -z "$student_id" ]] && read -r -p "Student ID: " student_id; }
    [[ -z "$student_class" ]] && { student_class=$(ctu_config_get student.class 2>/dev/null || true); [[ -z "$student_class" ]] && read -r -p "Class: " student_class; }
    [[ -z "$advisor_name" ]] && { advisor_name=$(ctu_config_get advisor.name 2>/dev/null || true); [[ -z "$advisor_name" ]] && read -r -p "Advisor name (e.g., TS. Tran Thi B): " advisor_name; }
    [[ -z "$advisor_title" ]] && { advisor_title=$(ctu_config_get advisor.title 2>/dev/null || true); [[ -z "$advisor_title" ]] && read -r -p "Advisor title (e.g., TS., Dr.): " advisor_title; }
    [[ -z "$title" ]] && read -r -p "Thesis title: " title
  fi

  # Apply config fallbacks for values still empty
  [[ -z "$student_name" ]] && student_name=$(ctu_config_get student.name 2>/dev/null || echo "YOUR NAME HERE")
  [[ -z "$student_id" ]] && student_id=$(ctu_config_get student.id 2>/dev/null || echo "B0000000")
  [[ -z "$student_class" ]] && student_class=$(ctu_config_get student.class 2>/dev/null || echo "YOUR CLASS")
  [[ -z "$advisor_name" ]] && advisor_name=$(ctu_config_get advisor.name 2>/dev/null || echo "YOUR ADVISOR")
  [[ -z "$advisor_title" ]] && advisor_title=$(ctu_config_get advisor.title 2>/dev/null || echo "Dr.")
  [[ -z "$title" ]] && title="YOUR THESIS TITLE"

  # Auto-generated values
  local short_title="${title:0:50}"
  local year
  year=$(date +%Y)
  local thesis_date
  thesis_date="$(date +'%B %Y')"
  local thesis_date_vi="Tháng $(date +'%m/%Y')"
  local thesis_degree="BACHELOR OF ENGINEERING"
  local thesis_degree_vi="KỸ SƯ"
  local major_vi
  major_vi=$(_ctu_init_vi_val major "$major")
  local program_vi
  program_vi=$(_ctu_init_vi_val program "$program")

  local title_vi="$title"
  local short_title_vi="${title_vi:0:50}"
  local location_vi="Cần Thơ"

  ctu_log_info "Creating project: $project_path/"

  # Copy template
  if [[ -d "$CTU_TEMPLATES_DIR" ]] && [[ -f "$CTU_TEMPLATES_DIR/main.typ" ]]; then
    cp -r "$CTU_TEMPLATES_DIR" "$abs_path"
    ctu_log_ok "Copied templates from cache"
  else
    ctu_log_warn "No cached templates found. Creating minimal project."
    mkdir -p "$abs_path/chapters" "$abs_path/frontmatter" "$abs_path/backmatter" "$abs_path/template" "$abs_path/images/logo"
    # Write minimal main.typ and info.typ
    cat > "$abs_path/main.typ" << 'TMIN'
#set page(width: auto, height: auto)
#set text(font: "Times New Roman", size: 13pt)
= The Thesis
Your content here.
TMIN
  fi

  # Replace placeholders in info.typ
  if [[ -f "$abs_path/info.typ" ]]; then
    ctu_placeholders_replace "$abs_path/info.typ" \
      STUDENT_NAME "$student_name" \
      STUDENT_ID "$student_id" \
      STUDENT_CLASS "$student_class" \
      ADVISOR_NAME "$advisor_name" \
      ADVISOR_TITLE "$advisor_title" \
      THESIS_TITLE "$title" \
      THESIS_TITLE_VI "$title_vi" \
      SHORT_TITLE "$short_title" \
      SHORT_TITLE_VI "$short_title_vi" \
      LANG "$lang" \
      THESIS_TYPE "$thesis_type" \
      MAJOR "$major" \
      MAJOR_VI "$major_vi" \
      PROGRAM "$program" \
      PROGRAM_VI "$program_vi" \
      THESIS_DATE "$thesis_date" \
      THESIS_DATE_VI "$thesis_date_vi" \
      THESIS_LOCATION "$location" \
      THESIS_LOCATION_VI "$location_vi" \
      THESIS_DEGREE "$thesis_degree" \
      THESIS_DEGREE_VI "$thesis_degree_vi"
    ctu_log_ok "Replaced placeholders"
  fi

  # Create .ctu-thesisrc
  cat > "$abs_path/.ctu-thesisrc" << RCEOF
[project]
name=$(basename "$project_path")
lang=$lang
type=$thesis_type

[student]
name=$student_name
id=$student_id
class=$student_class

[advisor]
name=$advisor_name
title=$advisor_title

[chapter]
prefix=chapter
padding=2
auto_renumber=true
RCEOF
  ctu_log_ok "Created .ctu-thesisrc"

  ctu_log_ok ""
  ctu_log_ok "Done! Next steps:"
  echo "  cd $project_path"
  echo "  ctu-thesis build          # Compile to PDF"
  echo "  ctu-thesis build --watch  # Auto-recompile on save"
  echo "  ctu-thesis chapter add 'Chapter Title'  # Add a chapter"
}

ctu_init "${COMMAND_ARGS[@]}"
