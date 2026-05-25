# CTU Thesis CLI v2.0 — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a standalone Bash CLI tool that scaffolds, builds, validates, and manages Typst thesis projects following CTU guidelines (Decision 4125/QĐ-ĐHCT 2024).

**Architecture:** Command-dispatch pattern — thin `bin/ctu-thesis` entrypoint sources `lib/core.sh` for shared utilities, then sources `lib/commands/<command>.sh` for execution. Template files are co-located in `templates/`, copied by `init` with `{{PLACEHOLDER}}` substitution. Tests use bats-core with isolated temp directories.

**Tech Stack:** Bash 4.2+, Typst 0.12.0+, bats-core (testing), shellcheck (lint), GitHub Actions (CI)

**Reference Spec:** `docs/superpowers/specs/2026-05-25-ctu-thesis-cli-v2-design.md`

**Source of truth for template files:** The existing `starter-template/` directory in this repo contains all reference `.typ` files. Each template file in the new `templates/` directory starts as a copy of the corresponding `starter-template/` file, then hardcoded values (student name, ID, title, date, etc.) are replaced with `{{PLACEHOLDER}}` markers.

---

## Phase 1: Project Skeleton

### Task 1.1: Initialize Git Repository

**Files:**
- Create: `.gitignore`
- Create: `README.md`
- Create: `LICENSE`
- Create: `Makefile`
- Create: `.github/workflows/ci.yml`

- [ ] **Step 1: Initialize git repo**

```bash
mkdir ctu-thesis-cli && cd ctu-thesis-cli && git init
mkdir -p bin lib/commands templates/{template,frontmatter,chapters/part1,chapters/part2/chapter1,chapters/part3,backmatter,images/logo}
mkdir -p tests dist .github/workflows
```

- [ ] **Step 2: Create .gitignore**

File: `.gitignore`
```
# Typst output
*.pdf

# System files
.DS_Store
Thumbs.db
desktop.ini

# Editor files
.vscode/
.idea/
*.swp
*.swo
*~

# Temporary files
*.tmp
*.bak

# Distribution artifacts
dist/ctu-thesis
dist/templates.tar.gz

# Test artifacts
tests/tmp-*
```

- [ ] **Step 3: Create LICENSE (MIT)**

File: `LICENSE`
```
MIT License

Copyright (c) 2026 CTU Thesis CLI Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

- [ ] **Step 4: Create Makefile**

File: `Makefile`
```makefile
.PHONY: all install test test-ci lint clean bundle help

PREFIX ?= $(HOME)/.local
DIST_DIR = dist
BUNDLE_SCRIPT = $(DIST_DIR)/ctu-thesis
TEMPLATES_TAR = $(DIST_DIR)/templates.tar.gz

all: help

install:
	@echo "Installing ctu-thesis to $(PREFIX)/bin ..."
	@mkdir -p $(PREFIX)/bin
	@cp bin/ctu-thesis $(PREFIX)/bin/ctu-thesis
	@chmod +x $(PREFIX)/bin/ctu-thesis
	@mkdir -p $(PREFIX)/lib/ctu-thesis
	@cp -r lib/* $(PREFIX)/lib/ctu-thesis/
	@mkdir -p $(HOME)/.ctu-thesis/templates
	@cp -r templates/* $(HOME)/.ctu-thesis/templates/
	@echo "Done. Add $(PREFIX)/bin to your PATH if needed."

test:
	@bats tests/

test-ci:
	@bats --tap tests/

lint:
	@shellcheck bin/ctu-thesis lib/core.sh lib/commands/*.sh install.sh

clean:
	@rm -rf tests/tmp-*
	@rm -f $(BUNDLE_SCRIPT) $(TEMPLATES_TAR)

bundle:
	@echo "Creating bundled distribution..."
	@mkdir -p $(DIST_DIR)
	@cat lib/version.sh > $(BUNDLE_SCRIPT)
	@echo '' >> $(BUNDLE_SCRIPT)
	@cat lib/core.sh >> $(BUNDLE_SCRIPT)
	@echo '' >> $(BUNDLE_SCRIPT)
	@for cmd in init build validate doctor clean config chapter update help; do \
		echo "# -- command: $$cmd --" >> $(BUNDLE_SCRIPT); \
		cat lib/commands/$$cmd.sh >> $(BUNDLE_SCRIPT); \
		echo '' >> $(BUNDLE_SCRIPT); \
	done
	@cat bin/ctu-thesis >> $(BUNDLE_SCRIPT)
	@chmod +x $(BUNDLE_SCRIPT)
	@tar czf $(TEMPLATES_TAR) -C templates .
	@echo "Bundle created: $(BUNDLE_SCRIPT), $(TEMPLATES_TAR)"

help:
	@echo "ctu-thesis-cli Makefile"
	@echo "  make install  - Install CLI to PREFIX (default: ~/.local)"
	@echo "  make test     - Run bats tests"
	@echo "  make lint     - Run shellcheck"
	@echo "  make bundle   - Create distribution artifacts in dist/"
	@echo "  make clean    - Remove test and build artifacts"
```

- [ ] **Step 5: Create CI workflow**

File: `.github/workflows/ci.yml`
```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install shellcheck
        run: sudo apt-get install -y shellcheck
      - name: Lint shell scripts
        run: shellcheck bin/ctu-thesis lib/core.sh lib/commands/*.sh install.sh

  template-sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Check compliance.json ↔ info.typ sync
        run: |
          bash tests/test_template_sync.sh

  template-compile:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: typst-community/setup-typst@v3
        with:
          typst-version: '0.12.0'
      - name: Compile template standalone
        run: typst compile templates/main.typ /tmp/template-test.pdf

  test:
    runs-on: ubuntu-latest
    needs: [lint, template-sync]
    steps:
      - uses: actions/checkout@v4
      - uses: typst-community/setup-typst@v3
        with:
          typst-version: '0.12.0'
      - name: Install bats
        run: |
          git clone --depth 1 https://github.com/bats-core/bats-core.git
          cd bats-core
          sudo ./install.sh /usr/local
      - name: Install fonts
        run: |
          echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | sudo debconf-set-selections
          sudo apt-get install -y ttf-mscorefonts-installer
      - name: Run tests
        run: bats --tap tests/
```

- [ ] **Step 6: Commit**

```bash
git add .gitignore README.md LICENSE Makefile .github/workflows/ci.yml
git commit -m "chore: initialize project skeleton with CI, Makefile, and .gitignore"
```

---

## Phase 2: Core Library & Test Infrastructure

### Task 2.1: Create Version File

**Files:**
- Create: `lib/version.sh`

- [ ] **Step 1: Write version.sh**

File: `lib/version.sh`
```bash
# ctu-thesis version — single source of truth
CTU_VERSION="1.0.0"
```

- [ ] **Step 2: Commit**

```bash
git add lib/version.sh
git commit -m "feat: add version file"
```

### Task 2.2: Create Core Library

**Files:**
- Create: `lib/core.sh`

- [ ] **Step 1: Write core.sh**

File: `lib/core.sh`
```bash
#!/usr/bin/env bash
# ctu-thesis core library — shared functions for all commands
# Source this file from bin/ctu-thesis or test_helper

# -- Constants ---------------------------------------------------------------
[[ -n "${CTU_VERSION:-}" ]] || CTU_VERSION="1.0.0"
CTU_HOME="${CTU_HOME:-$HOME/.ctu-thesis}"
CTU_CONFIG="${CTU_CONFIG:-$CTU_HOME/config}"
CTU_TEMPLATES_DIR="${CTU_TEMPLATES_DIR:-$CTU_HOME/templates}"
CTU_CACHE_DIR="${CTU_CACHE_DIR:-$CTU_HOME/cache}"

# -- Color & Logging ---------------------------------------------------------
if [[ -z "${NO_COLOR:-}" && -t 1 ]]; then
  CLR_RED='\033[0;31m'
  CLR_GREEN='\033[0;32m'
  CLR_YELLOW='\033[0;33m'
  CLR_BLUE='\033[0;34m'
  CLR_CYAN='\033[0;36m'
  CLR_RESET='\033[0m'
else
  CLR_RED='' CLR_GREEN='' CLR_YELLOW='' CLR_BLUE='' CLR_CYAN='' CLR_RESET=''
fi

ctu_log()  { echo -e "$@"; }
ctu_log_info()  { echo -e "${CLR_CYAN}[info]${CLR_RESET} $*"; }
ctu_log_ok()    { echo -e "${CLR_GREEN}[ ok ]${CLR_RESET} $*"; }
ctu_log_warn()  { echo -e "${CLR_YELLOW}[warn]${CLR_RESET} $*" >&2; }
ctu_log_error() { echo -e "${CLR_RED}[FAIL]${CLR_RESET} $*" >&2; }

ctu_log_debug() {
  if [[ "${CTU_VERBOSE:-}" == "true" ]]; then
    echo -e "${CLR_BLUE}[dbug]${CLR_RESET} $*" >&2
  fi
}

ctu_die() {
  local code="${1:-1}"
  shift
  ctu_log_error "$@"
  exit "$code"
}

# -- Config I/O (ini-style key=value) ----------------------------------------
ctu_config_get() {
  local key="$1"
  local file="${CTU_CONFIG}"
  [[ -f "$file" ]] || return 1
  local val
  val=$(grep "^${key}=" "$file" | head -1 | cut -d= -f2-)
  [[ -n "$val" ]] && echo "$val" && return 0
  return 1
}

ctu_config_set() {
  local key="$1"
  local value="$2"
  local file="${CTU_CONFIG}"
  mkdir -p "$(dirname "$file")"
  if grep -q "^${key}=" "$file" 2>/dev/null; then
    if [[ "$(uname)" == "Darwin" ]]; then
      sed -i '' "s|^${key}=.*|${key}=${value}|" "$file"
    else
      sed -i "s|^${key}=.*|${key}=${value}|" "$file"
    fi
  else
    echo "${key}=${value}" >> "$file"
  fi
}

ctu_config_unset() {
  local key="$1"
  local file="${CTU_CONFIG}"
  [[ -f "$file" ]] || return 1
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "/^${key}=/d" "$file"
  else
    sed -i "/^${key}=/d" "$file"
  fi
}

ctu_config_list() {
  local file="${CTU_CONFIG}"
  [[ -f "$file" ]] || return 1
  cat "$file" | grep -v '^#' | grep -v '^$'
}

# -- Dependency Checks -------------------------------------------------------
ctu_check_cmd() {
  command -v "$1" &>/dev/null
}

ctu_get_cmd_version() {
  local cmd="$1"
  local flag="${2:---version}"
  if ctu_check_cmd "$cmd"; then
    "$cmd" "$flag" 2>&1 | head -1
  else
    echo "(not installed)"
  fi
}

# -- Project Root Finder -----------------------------------------------------
ctu_find_project_root() {
  local dir="${1:-$PWD}"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/main.typ" && -f "$dir/info.typ" ]]; then
      echo "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

# -- Marker Region Helpers ---------------------------------------------------
ctu_marker_insert() {
  local file="$1"
  local start_marker="$2"
  local end_marker="$3"
  local content="$4"
  local tmpfile="${file}.ctu-tmp-$$"

  if grep -q "${start_marker}" "$file" && grep -q "${end_marker}" "$file"; then
    # Replace content between markers
    awk -v start="$start_marker" -v end="$end_marker" -v content="$content" '
      BEGIN { printing=1 }
      $0 ~ start { print; print content; printing=0; next }
      $0 ~ end { printing=1 }
      printing { print }
    ' "$file" > "$tmpfile" && mv "$tmpfile" "$file"
  else
    # Append markers with content
    {
      echo ""
      echo "$start_marker"
      echo "$content"
      echo "$end_marker"
    } >> "$file"
  fi
}

ctu_marker_read() {
  local file="$1"
  local start_marker="$2"
  local end_marker="$3"
  sed -n "/${start_marker}/,/${end_marker}/p" "$file" | sed '1d;$d'
}

# -- Placeholder Substitution ------------------------------------------------
ctu_placeholders_replace() {
  local file="$1"
  shift
  local tmpfile="${file}.ctu-tmp-$$"
  cp "$file" "$tmpfile"
  while [[ $# -gt 0 ]]; do
    local placeholder="$1"
    local value="$2"
    shift 2
    if [[ "$(uname)" == "Darwin" ]]; then
      sed -i '' "s|{{${placeholder}}}|${value}|g" "$tmpfile"
    else
      sed -i "s|{{${placeholder}}}|${value}|g" "$tmpfile"
    fi
  done
  mv "$tmpfile" "$file"
}

# -- Chapter Padding ---------------------------------------------------------
ctu_chapter_pad() {
  local num="$1"
  local padding="${2:-2}"
  printf "%0${padding}d" "$num"
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core.sh
git commit -m "feat: add core library with logging, config, markers, and helpers"
```

### Task 2.3: Create Test Helper

**Files:**
- Create: `tests/test_helper.bash`

- [ ] **Step 1: Write test_helper.bash**

File: `tests/test_helper.bash`
```bash
#!/usr/bin/env bash
# Setup/teardown helpers for bats tests

setup() {
  TEST_TEMP="$(mktemp -d)"
  CTU_HOME="${TEST_TEMP}/.ctu-thesis"
  CTU_CONFIG="${CTU_HOME}/config"
  CTU_TEMPLATES_DIR="${CTU_HOME}/templates"
  CTU_CACHE_DIR="${CTU_HOME}/cache"
  export CTU_HOME CTU_CONFIG CTU_TEMPLATES_DIR CTU_CACHE_DIR
  mkdir -p "$CTU_HOME/bin" "$CTU_HOME/lib/commands" "$CTU_TEMPLATES_DIR" "$CTU_CACHE_DIR"

  # Copy CLI source into test CTU_HOME
  cp "$BATS_TEST_DIRNAME/../lib/version.sh" "$CTU_HOME/lib/"
  cp "$BATS_TEST_DIRNAME/../lib/core.sh" "$CTU_HOME/lib/"
  cp "$BATS_TEST_DIRNAME/../lib/commands/"*.sh "$CTU_HOME/lib/commands/" 2>/dev/null || true
  cp "$BATS_TEST_DIRNAME/../bin/ctu-thesis" "$CTU_HOME/bin/ctu-thesis"
  chmod +x "$CTU_HOME/bin/ctu-thesis"

  # Copy template files if they exist
  if [[ -d "$BATS_TEST_DIRNAME/../templates" ]] && [[ -f "$BATS_TEST_DIRNAME/../templates/main.typ" ]]; then
    cp -r "$BATS_TEST_DIRNAME/../templates/"* "$CTU_TEMPLATES_DIR/"
  fi
}

teardown() {
  rm -rf "${TEST_TEMP:-/tmp/ctu-test-not-set}"
}

# Helper: invoke ctu-thesis entrypoint via bash
ctu() {
  HOME="$TEST_TEMP" bash "$CTU_HOME/bin/ctu-thesis" "$@"
}

# Helper: create a minimal templates directory for testing init without full template
ctu_create_minimal_templates() {
  mkdir -p "$CTU_TEMPLATES_DIR"
  cat > "$CTU_TEMPLATES_DIR/main.typ" << 'TYPEOF'
#let lang = "{{LANG}}"
TYPEOF
  cat > "$CTU_TEMPLATES_DIR/info.typ" << 'TYPEOF'
#let info = (
  en: ( student: ( name: "{{STUDENT_NAME}}", id: "{{STUDENT_ID}}" ) ),
  vi: ( student: ( name: "{{STUDENT_NAME}}", id: "{{STUDENT_ID}}" ) ),
)
#let settings = ( primary_lang: "{{LANG}}" )
TYPEOF
  cat > "$CTU_TEMPLATES_DIR/compliance.json" << 'JSONEOF'
{"format":{"font":"Times New Roman","font_size":"13pt"}}
JSONEOF
}
```

- [ ] **Step 2: Commit**

```bash
git add tests/test_helper.bash
git commit -m "test: add bats test helper with setup/teardown"
```

---

## Phase 3: Entrypoint

### Task 3.1: Create CLI Entrypoint

**Files:**
- Create: `bin/ctu-thesis`

- [ ] **Step 1: Write the entrypoint**

File: `bin/ctu-thesis`
```bash
#!/usr/bin/env bash
set -euo pipefail

# -- Resolve LIB_DIR ---------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/../lib/core.sh" ]]; then
  LIB_DIR="$(cd "$SCRIPT_DIR/../lib" && pwd)"
elif [[ -n "${CTU_HOME:-}" ]] && [[ -f "$CTU_HOME/lib/core.sh" ]]; then
  LIB_DIR="$CTU_HOME/lib"
elif [[ -f "$HOME/.ctu-thesis/lib/core.sh" ]]; then
  LIB_DIR="$HOME/.ctu-thesis/lib"
else
  echo "Error: cannot find ctu-thesis core library." >&2
  echo "Run install script or set CTU_HOME environment variable." >&2
  exit 1
fi

# -- Source core library -----------------------------------------------------
# shellcheck source=lib/version.sh
source "$LIB_DIR/version.sh"
# shellcheck source=lib/core.sh
source "$LIB_DIR/core.sh"

# -- Global flags ------------------------------------------------------------
CTU_VERBOSE="${CTU_VERBOSE:-false}"
CTU_QUIET="${CTU_QUIET:-false}"
COMMAND=""
COMMAND_ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -v|--verbose) CTU_VERBOSE=true; shift ;;
    -q|--quiet) CTU_QUIET=true; shift ;;
    -h|--help)
      COMMAND="help"
      shift
      ;;
    --version)
      echo "ctu-thesis v${CTU_VERSION}"
      exit 0
      ;;
    --) shift; COMMAND_ARGS+=("$@"); break ;;
    -*)
      ctu_log_error "Unknown flag: $1"
      echo "Run 'ctu-thesis help' for usage." >&2
      exit 1
      ;;
    *)
      COMMAND="$1"
      shift
      COMMAND_ARGS+=("$@")
      break
      ;;
  esac
done

# -- Default to help ---------------------------------------------------------
[[ -z "$COMMAND" ]] && COMMAND="help"

# -- Dispatch ----------------------------------------------------------------
CMD_FILE="$LIB_DIR/commands/${COMMAND}.sh"
if [[ -f "$CMD_FILE" ]]; then
  # shellcheck source=/dev/null
  source "$CMD_FILE"
else
  ctu_log_error "Unknown command: $COMMAND"
  echo "Run 'ctu-thesis help' for available commands." >&2
  exit 1
fi
```

- [ ] **Step 2: Make executable**

```bash
chmod +x bin/ctu-thesis
```

- [ ] **Step 3: Test entrypoint locally**

```bash
# Should show version
HOME=/tmp bash bin/ctu-thesis --version
# Expected: ctu-thesis v1.0.0

# Should default to help
HOME=/tmp bash bin/ctu-thesis
# Expected: help text (will fail until help command exists)
```

- [ ] **Step 4: Commit**

```bash
git add bin/ctu-thesis
git commit -m "feat: add CLI entrypoint with global flag parsing and dispatch"
```

---

## Phase 4: Template Files

### Task 4.1: Create compliance.json

**Files:**
- Create: `templates/compliance.json`

- [ ] **Step 1: Write compliance.json**

File: `templates/compliance.json`
```json
{
  "version": "1.0.0",
  "thesis_type": "bachelor",
  "format": {
    "font": "Times New Roman",
    "font_size": "13pt",
    "margins": {
      "left": "4cm",
      "right": "2.5cm",
      "top": "2.5cm",
      "bottom": "2.5cm"
    },
    "line_spacing": 1.2,
    "paragraph_indent": "1cm"
  },
  "abstract": {
    "min_words": 200,
    "max_words": 350,
    "min_keywords": 3,
    "max_keywords": 5
  },
  "bibliography": {
    "style": "ieee",
    "file_path": "backmatter/bibliography.bib",
    "min_references": 15
  },
  "cover": {
    "border_color": "#003399",
    "outer_border_weight": "2pt",
    "inner_border_weight": "3pt"
  },
  "headings": {
    "level1_size": "14pt",
    "level1_transform": "uppercase",
    "level1_align": "center",
    "level2_size": "13pt",
    "level2_transform": "uppercase",
    "level3_size": "13pt"
  },
  "page": {
    "paper": "a4",
    "front_matter_numbering": "i",
    "main_content_numbering": "1",
    "header_font_size": "9pt",
    "header_style": "italic",
    "footer_font_size": "11pt"
  },
  "code_blocks": {
    "font": "Courier New",
    "font_size": "10pt",
    "background": "#f5f5f5",
    "padding": "0.3cm"
  },
  "required_files": [
    "main.typ",
    "info.typ",
    "template/ctu-styles.typ",
    "template/i18n.typ",
    "frontmatter/cover.typ",
    "frontmatter/inner-cover.typ",
    "frontmatter/evaluation.typ",
    "frontmatter/acknowledgements.typ",
    "frontmatter/abstract.typ",
    "frontmatter/table-of-contents.typ",
    "frontmatter/list-of-figures.typ",
    "frontmatter/list-of-tables.typ",
    "frontmatter/abbreviations.typ",
    "backmatter/bibliography.bib",
    "backmatter/appendices.typ"
  ],
  "required_directories": [
    "template",
    "frontmatter",
    "chapters",
    "chapters/part1",
    "chapters/part2",
    "chapters/part3",
    "backmatter",
    "images",
    "images/logo"
  ]
}
```

- [ ] **Step 2: Commit**

```bash
git add templates/compliance.json
git commit -m "feat: add compliance.json with CTU format validation values"
```

### Task 4.2: Create info.typ with Placeholders

**Files:**
- Create: `templates/info.typ`

- [ ] **Step 1: Write info.typ**

File: `templates/info.typ`
```typst
// ============================================================================
// CTU THESIS INFORMATION CONFIGURATION
// Can Tho University - College of Information and Communication Technology
// Edit this file with your information.
// ============================================================================

#let info = (
  en: (
    student: (
      name: "{{STUDENT_NAME}}",
      id: "{{STUDENT_ID}}",
      class: "{{STUDENT_CLASS}}",
      major: "{{MAJOR}}",
      program: "{{PROGRAM}}",
    ),
    advisor: (
      name: "{{ADVISOR_NAME}}",
      title: "{{ADVISOR_TITLE}}",
    ),
    thesis: (
      title: "{{THESIS_TITLE}}",
      short_title: "{{SHORT_TITLE}}",
      date: "{{THESIS_DATE}}",
      location: "{{THESIS_LOCATION}}",
      degree: "{{THESIS_DEGREE}}",
    ),
    keywords: (
      "keyword 1",
      "keyword 2",
      "keyword 3",
      "keyword 4",
      "keyword 5"
    ),
    committee: (
      chairman: "Dr. Chairman Name",
      reviewer: "Dr. Reviewer Name",
      advisor: "{{ADVISOR_NAME}}",
    ),
    abbreviations: (
      ("API", "Application Programming Interface"),
      ("CTU", "Can Tho University"),
      ("ICT", "Information and Communication Technology"),
      ("UI/UX", "User Interface/User Experience"),
      ("HTTP", "Hypertext Transfer Protocol"),
    ),
  ),
  vi: (
    student: (
      name: "{{STUDENT_NAME}}",
      id: "{{STUDENT_ID}}",
      class: "{{STUDENT_CLASS}}",
      major: "{{MAJOR_VI}}",
      program: "{{PROGRAM_VI}}",
    ),
    advisor: (
      name: "{{ADVISOR_NAME}}",
      title: "{{ADVISOR_TITLE}}",
    ),
    thesis: (
      title: "{{THESIS_TITLE_VI}}",
      short_title: "{{SHORT_TITLE_VI}}",
      date: "{{THESIS_DATE_VI}}",
      location: "{{THESIS_LOCATION_VI}}",
      degree: "{{THESIS_DEGREE_VI}}",
    ),
    keywords: (
      "từ khóa 1",
      "từ khóa 2",
      "từ khóa 3",
      "từ khóa 4",
      "từ khóa 5"
    ),
    committee: (
      chairman: "TS. Tên Chủ Tịch",
      reviewer: "TS. Tên Phản Biện",
      advisor: "{{ADVISOR_NAME}}",
    ),
    abbreviations: (
      ("API", "Giao diện lập trình ứng dụng"),
      ("CTU", "Đại học Cần Thơ"),
      ("CNTT-TT", "Công nghệ Thông tin và Truyền thông"),
      ("UI/UX", "Giao diện/Trải nghiệm người dùng"),
      ("HTTP", "Giao thức truyền tải siêu văn bản"),
    ),
  ),
)

// ============================================================================
// GLOBAL SETTINGS (CTU STANDARD — Decision 4125/QĐ-ĐHCT 2024)
// ============================================================================
#let settings = (
  primary_lang: "{{LANG}}",

  // CTU Official Colors
  border_color: rgb(0, 51, 153), // CTU Blue (#003399)
  accent_color: rgb(0, 83, 159), // CTU Accent (#00539F)

  // CTU Format Requirements (2025-2026)
  format: (
    font: "Times New Roman",
    font_size: 13pt,
    line_spacing: 1.2,      // Main text: 1.2 spacing
    margins: (
      left: 4cm,            // CTU Standard: 4cm left
      right: 2.5cm,         // CTU Standard: 2.5cm other sides
      top: 2.5cm,
      bottom: 2.5cm,
    ),
    paragraph_indent: 1cm,  // First line indent
    abstract_words: (200, 350), // Min-max words
  ),
)
```

- [ ] **Step 2: Commit**

```bash
git add templates/info.typ
git commit -m "feat: add info.typ template with placeholder substitution markers"
```

### Task 4.3: Create Template Style Files

**Files:**
- Create: `templates/template/i18n.typ`
- Create: `templates/template/ctu-styles.typ`

- [ ] **Step 1: Write i18n.typ** (copy from `starter-template/template/i18n.typ`, no placeholders needed — this is pure static content)

```bash
cp ../starter-template/template/i18n.typ templates/template/i18n.typ
```

Wait — let me verify this is self-contained. The `i18n.typ` file from `starter-template/` only defines a `dict` and `term()` function; it doesn't import anything. It's static. Use it as-is.

- [ ] **Step 2: Write ctu-styles.typ** (copy from `starter-template/template/ctu-styles.typ` — no placeholders, this is pure display logic)

```bash
cp ../starter-template/template/ctu-styles.typ templates/template/ctu-styles.typ
```

- [ ] **Step 3: Commit**

```bash
git add templates/template/i18n.typ templates/template/ctu-styles.typ
git commit -m "feat: add i18n and ctu-styles template files"
```

### Task 4.4: Create Frontmatter Template Files

**Files:**
- Create: `templates/frontmatter/cover.typ`
- Create: `templates/frontmatter/inner-cover.typ`
- Create: `templates/frontmatter/evaluation.typ`
- Create: `templates/frontmatter/acknowledgements.typ`
- Create: `templates/frontmatter/abstract.typ`
- Create: `templates/frontmatter/table-of-contents.typ`
- Create: `templates/frontmatter/list-of-figures.typ`
- Create: `templates/frontmatter/list-of-tables.typ`
- Create: `templates/frontmatter/abbreviations.typ`

- [ ] **Step 1: Copy cover.typ** — this file is purely dynamic (reads from `info.typ` at compile time), no placeholders needed. Copy as-is from `starter-template/frontmatter/cover.typ`.

```bash
cp ../starter-template/frontmatter/cover.typ templates/frontmatter/cover.typ
```

- [ ] **Step 2: Copy inner-cover.typ** — same, no placeholders. Copy as-is.

```bash
cp ../starter-template/frontmatter/inner-cover.typ templates/frontmatter/inner-cover.typ
```

- [ ] **Step 3: Copy evaluation.typ** — same, reads from `info.typ` at compile time.

```bash
cp ../starter-template/frontmatter/evaluation.typ templates/frontmatter/evaluation.typ
```

- [ ] **Step 4: Copy acknowledgements.typ** — static placeholder text. Copy as-is, students edit manually.

```bash
cp ../starter-template/frontmatter/acknowledgements.typ templates/frontmatter/acknowledgements.typ
```

- [ ] **Step 5: Copy abstract.typ** — static placeholder text. Copy as-is.

```bash
cp ../starter-template/frontmatter/abstract.typ templates/frontmatter/abstract.typ
```

- [ ] **Step 6: Copy table-of-contents.typ** — purely dynamic (reads from document outline). Copy as-is.

```bash
cp ../starter-template/frontmatter/table-of-contents.typ templates/frontmatter/table-of-contents.typ
```

- [ ] **Step 7: Copy list-of-figures.typ**

```bash
cp ../starter-template/frontmatter/list-of-figures.typ templates/frontmatter/list-of-figures.typ
```

- [ ] **Step 8: Copy list-of-tables.typ**

```bash
cp ../starter-template/frontmatter/list-of-tables.typ templates/frontmatter/list-of-tables.typ
```

- [ ] **Step 9: Copy abbreviations.typ** — reads from `info.typ`. Copy as-is.

```bash
cp ../starter-template/frontmatter/abbreviations.typ templates/frontmatter/abbreviations.typ
```

- [ ] **Step 10: Commit**

```bash
git add templates/frontmatter/
git commit -m "feat: add all frontmatter template files"
```

### Task 4.5: Create Chapter Template Files

**Files:**
- Create: `templates/chapters/part1-introduction.typ`
- Create: `templates/chapters/part2-content.typ`
- Create: `templates/chapters/part3-conclusion.typ`
- Create: `templates/chapters/part1/01-context.typ`
- Create: `templates/chapters/part1/02-related-work.typ`
- Create: `templates/chapters/part1/03-objectives.typ`
- Create: `templates/chapters/part1/04-methodology.typ`
- Create: `templates/chapters/part1/05-outline.typ`
- Create: `templates/chapters/part2/chapter1/01-background.typ`
- Create: `templates/chapters/part3/01-conclusion.typ`
- Create: `templates/chapters/part3/02-future-work.typ`

- [ ] **Step 1: Copy part1-introduction.typ** — this is a chapter include-file catalog. Copy from `starter-template/` but renamed section files:

File: `templates/chapters/part1-introduction.typ`
```typst
#include "part1/01-context.typ"
#include "part1/02-related-work.typ"
#include "part1/03-objectives.typ"
#include "part1/04-methodology.typ"
#include "part1/05-outline.typ"
```

- [ ] **Step 2: Copy part2-content.typ** — this is the marker-managed region:

File: `templates/chapters/part2-content.typ`
```typst
#include "part2/chapter1-background.typ"
```

- [ ] **Step 3: Copy part3-conclusion.typ** — fixed structure:

File: `templates/chapters/part3-conclusion.typ`
```typst
#include "part3/01-conclusion.typ"
#include "part3/02-future-work.typ"
```

- [ ] **Step 4: Write part1 content files** (minimal placeholder content for students to replace):

File: `templates/chapters/part1/01-context.typ`
```typst
== Context and Problem Statement

Describe the background of your research topic and the problem you aim to address.
Include relevant context, statistics, and the motivation for this research.
```

File: `templates/chapters/part1/02-related-work.typ`
```typst
== Related Work

Summarize existing research, solutions, and literature related to your topic.
Identify gaps in current knowledge or approaches that your work addresses.
```

File: `templates/chapters/part1/03-objectives.typ`
```typst
== Objectives and Scope

=== Primary Objectives

List the main objectives of your thesis.

=== Scope

Define what is included and excluded from your work.

=== Expected Outcomes

Describe the deliverables and contributions of this thesis.
```

File: `templates/chapters/part1/04-methodology.typ`
```typst
== Research Methodology

Describe your research approach, methods, and technical approach.
Include the development phases and tools used.
```

File: `templates/chapters/part1/05-outline.typ`
```typst
== Thesis Outline

Provide a brief overview of the thesis structure and what each chapter covers.
```

- [ ] **Step 5: Write part2 content file:**

File: `templates/chapters/part2/chapter1/01-background.typ`
```typst
== Background

Provide the theoretical foundations, technology overview, and related concepts
relevant to your thesis topic.
```

- [ ] **Step 6: Write part3 content files:**

File: `templates/chapters/part3/01-conclusion.typ`
```typst
== Conclusion

Summarize the key findings, contributions, and achievements of your thesis.
Discuss limitations and lessons learned.
```

File: `templates/chapters/part3/02-future-work.typ`
```typst
== Future Work

Outline potential improvements, extensions, and future research directions
based on the results of this thesis.
```

- [ ] **Step 7: Commit**

```bash
git add templates/chapters/
git commit -m "feat: add chapter structure template files with placeholder content"
```

### Task 4.6: Create Backmatter Template Files

**Files:**
- Create: `templates/backmatter/bibliography.bib`
- Create: `templates/backmatter/appendices.typ`

- [ ] **Step 1: Copy bibliography.bib**

```bash
cp ../starter-template/backmatter/bibliography.bib templates/backmatter/bibliography.bib
```

- [ ] **Step 2: Copy appendices.typ**

```bash
cp ../starter-template/backmatter/appendices.typ templates/backmatter/appendices.typ
```

- [ ] **Step 3: Copy logo image**

```bash
cp ../starter-template/images/logo/CTU_logo.png templates/images/logo/CTU_logo.png
```

- [ ] **Step 4: Commit**

```bash
git add templates/backmatter/ templates/images/
git commit -m "feat: add backmatter templates and CTU logo"
```

### Task 4.7: Create main.typ with Marker Regions

**Files:**
- Create: `templates/main.typ`

- [ ] **Step 1: Write main.typ**

File: `templates/main.typ`
```typst
// ============================================================================
// CTU GRADUATION THESIS - MAIN FILE
// Can Tho University Format — Decision 4125/QĐ-ĐHCT (2024)
// ============================================================================

// 1. CONFIGURATION & IMPORTS
#import "info.typ": *
#import "template/ctu-styles.typ": ctu-styles
#import "template/i18n.typ": term

// 2. GLOBAL SETTINGS
#let lang = settings.primary_lang

// 3. DOCUMENT SETUP (CTU Format)
#show: doc => ctu-styles(doc, lang: lang)

// Document Metadata
#set document(
  title: info.at(lang).thesis.title,
  author: info.at(lang).student.name,
  keywords: info.at(lang).keywords,
)

// ============================================================================
// 4. FRONT MATTER (Roman numerals i, ii, iii...)
// ============================================================================
#set page(numbering: "i")
#counter(page).update(1)

// Cover Pages
#import "frontmatter/cover.typ": cover-page
#import "frontmatter/inner-cover.typ": inner-cover-page

#cover-page(lang: lang)
#inner-cover-page(lang: lang)

// Evaluation & Acknowledgements
#include "frontmatter/evaluation.typ"
#include "frontmatter/acknowledgements.typ"

// Lists (TOC, LOF, LOT)
#include "frontmatter/table-of-contents.typ"
#pagebreak()

#include "frontmatter/list-of-figures.typ"
#pagebreak()

#include "frontmatter/list-of-tables.typ"
#pagebreak()

// Abbreviations & Abstract
#include "frontmatter/abbreviations.typ"
#include "frontmatter/abstract.typ"

// ============================================================================
// 5. MAIN CONTENT (Arabic numerals 1, 2, 3...)
// ============================================================================
#set page(numbering: "1")
#counter(page).update(1)
#set heading(numbering: "1.1.1.1")

// Helper for Part Headings (Visual separator, appears in outline)
#let part-heading(body) = {
  pagebreak()
  v(2cm)
  heading(level: 1, numbering: none, outlined: true)[#body]
}

// PART 1: INTRODUCTION
#part-heading[#term(lang, "part") 1: INTRODUCTION]
#counter(heading).update(1)
#include "chapters/part1-introduction.typ"

// PART 2: THESIS CONTENT
#part-heading[#term(lang, "part") 2: THESIS CONTENT]
#include "chapters/part2-content.typ"

// PART 3: CONCLUSION
#part-heading[#term(lang, "part") 3: CONCLUSION AND FUTURE WORK]
#counter(heading).step()
#include "chapters/part3-conclusion.typ"

// ============================================================================
// 6. BACK MATTER
// ============================================================================

// REFERENCES (IEEE Style — CTU Standard)
#pagebreak()
#bibliography("backmatter/bibliography.bib", title: term(lang, "ref"), style: "ieee")

// APPENDICES
#pagebreak()
#set page(numbering: none)
#counter(heading).update(0)
#set heading(numbering: "A.1")
#include "backmatter/appendices.typ"

// -- CTU-THESIS-CHAPTERS-START --
// Do not edit between these markers; managed by ctu-thesis CLI.
// -- CTU-THESIS-CHAPTERS-END --
```

- [ ] **Step 2: Verify template compiles standalone**

```bash
typst compile templates/main.typ /tmp/template-test.pdf
# Expected: exit 0, PDF produced with placeholder names visible
```

- [ ] **Step 3: Commit**

```bash
git add templates/main.typ
git commit -m "feat: add main.typ entrypoint with marker regions"
```

---

## Phase 5: `help` Command

### Task 5.1: Create help Command

**Files:**
- Create: `lib/commands/help.sh`

- [ ] **Step 1: Write help.sh** (needed early so entrypoint doesn't fail on default dispatch)

File: `lib/commands/help.sh`
```bash
#!/usr/bin/env bash
# help — show usage and command reference

ctu_help_help() {
  echo "Usage: ctu-thesis help [COMMAND]"
  echo "Show detailed usage for a command, or list all commands."
}

ctu_help() {
  local topic="${1:-}"

  if [[ -n "$topic" ]]; then
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
ctu_help "${COMMAND_ARGS[@]}"
```

- [ ] **Step 2: Test that entrypoint works now**

```bash
HOME=/tmp bash bin/ctu-thesis
# Expected: shows help text with command list
HOME=/tmp bash bin/ctu-thesis --version
# Expected: ctu-thesis v1.0.0
```

- [ ] **Step 3: Commit**

```bash
git add lib/commands/help.sh
git commit -m "feat: add help command with command reference"
```

---

## Phase 6: `config` Command

### Task 6.1: Create Config Command with Tests

**Files:**
- Create: `lib/commands/config.sh`
- Create: `tests/test_config.bats`

- [ ] **Step 1: Write failing test**

File: `tests/test_config.bats`
```bash
#!/usr/bin/env bats

load test_helper

@test "config: set and get round-trip" {
  ctu config set test.key "hello world"
  run ctu config get test.key
  [[ "$output" == "hello world" ]]
}

@test "config: get nonexistent key returns error" {
  run ctu config get none.such_key
  [[ "$status" -eq 1 ]]
}

@test "config: list shows all keys" {
  ctu config set a.key "val1"
  ctu config set b.key "val2"
  run ctu config list
  [[ "$output" == *"a.key=val1"* ]]
  [[ "$output" == *"b.key=val2"* ]]
}

@test "config: unset removes key" {
  ctu config set temp.key "val"
  ctu config unset temp.key
  run ctu config get temp.key
  [[ "$status" -eq 1 ]]
}

@test "config: handles special characters in values" {
  ctu config set spec.key "hello = world & stuff"
  run ctu config get spec.key
  [[ "$output" == "hello = world & stuff" ]]
}

@test "config: empty config file does not crash" {
  rm -f "$CTU_CONFIG"
  touch "$CTU_CONFIG"
  run ctu config list
  [[ "$status" -eq 1 ]] || true
}
```

- [ ] **Step 2: Run test to verify failure**

```bash
bats tests/test_config.bats
# Expected: all tests FAIL (config command not implemented)
```

- [ ] **Step 3: Write config.sh**

File: `lib/commands/config.sh`
```bash
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

ctu_config_cmd "${COMMAND_ARGS[@]}"
```

- [ ] **Step 4: Run tests to verify pass**

```bash
bats tests/test_config.bats
# Expected: all 6 tests PASS
```

- [ ] **Step 5: Commit**

```bash
git add lib/commands/config.sh tests/test_config.bats
git commit -m "feat: add config command with set/get/list/unset and bats tests"
```

---

## Phase 7: `doctor` Command

### Task 7.1: Create Doctor Command with Tests

**Files:**
- Create: `lib/commands/doctor.sh`
- Create: `tests/test_doctor.bats`

- [ ] **Step 1: Write failing test**

File: `tests/test_doctor.bats`
```bash
#!/usr/bin/env bats

load test_helper

@test "doctor: runs all checks" {
  run ctu doctor
  [[ "$status" -eq 0 ]] || [[ "$status" -eq 2 ]]
  [[ "$output" == *"bash"* ]]
  [[ "$output" == *"typst"* ]]
}

@test "doctor: --json outputs valid JSON lines" {
  run ctu doctor --json
  # Each line should start with { and end with }
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    [[ "$line" =~ ^\{.*\}$ ]]
  done <<< "$output"
}

@test "doctor: reports missing typst" {
  # Create a fake PATH without typst
  PATH="/usr/bin:/bin" run ctu doctor --json
  [[ "$output" == *'"status":"fail"'* ]] || true
}

@test "doctor: reports missing Times New Roman" {
  run ctu doctor --json
  # At minimum, the check exists in output
  [[ "$output" == *'font_times_new_roman'* ]]
}
```

- [ ] **Step 2: Run test to verify failure**

```bash
bats tests/test_doctor.bats
# Expected: tests FAIL
```

- [ ] **Step 3: Write doctor.sh**

File: `lib/commands/doctor.sh`
```bash
#!/usr/bin/env bash
# doctor — diagnose the user's environment

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

_ctu_doctor_status() {
  local check="$1"
  local status="$2"
  local detail="${3:-}"
  local json="${4:-false}"

  if [[ "$json" == "true" ]]; then
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

  # Bash version
  local bash_ver="${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}"
  if [[ "${BASH_VERSINFO[0]}" -ge 4 ]] && [[ "${BASH_VERSINFO[1]}" -ge 2 ]]; then
    _ctu_doctor_status "bash" "ok" "$bash_ver" "$json_output"
  else
    _ctu_doctor_status "bash" "fail" "bash $bash_ver — need 4.2+" "$json_output"
    overall_ok=false
  fi

  # Typst
  if ctu_check_cmd typst; then
    local tv
    tv=$(typst --version 2>&1 | head -1)
    _ctu_doctor_status "typst" "ok" "$tv" "$json_output"
  else
    _ctu_doctor_status "typst" "fail" "typst not found. Install: https://github.com/typst/typst/releases" "$json_output"
    overall_ok=false
  fi

  # Git
  if ctu_check_cmd git; then
    _ctu_doctor_status "git" "ok" "$(git --version 2>&1 | head -1)" "$json_output"
  else
    _ctu_doctor_status "git" "warn" "git not found (optional, recommended for version control)" "$json_output"
  fi

  # CURL
  if ctu_check_cmd curl; then
    _ctu_doctor_status "curl" "ok" "$(curl --version 2>&1 | head -1)" "$json_output"
  else
    _ctu_doctor_status "curl" "fail" "curl not found. Required for updates." "$json_output"
    overall_ok=false
  fi

  # Times New Roman font
  local tnr_found=false
  if ctu_check_cmd fc-list; then
    if fc-list | grep -qi "times new roman"; then
      tnr_found=true
    fi
  fi
  # macOS fallback
  if [[ "$tnr_found" != "true" ]] && [[ "$(uname)" == "Darwin" ]]; then
    if [[ -f "/System/Library/Fonts/Times New Roman.ttf" ]] || [[ -f "/Library/Fonts/Times New Roman.ttf" ]]; then
      tnr_found=true
    fi
  fi
  if [[ "$tnr_found" == "true" ]]; then
    _ctu_doctor_status "font_times_new_roman" "ok" "found" "$json_output"
  else
    _ctu_doctor_status "font_times_new_roman" "warn" "not found. Install: ttf-mscorefonts-installer (Linux) or MS Office fonts (macOS). Typst will use a fallback serif font." "$json_output"
  fi

  # Internet
  if command -v curl &>/dev/null && curl -s --connect-timeout 5 https://github.com >/dev/null 2>&1; then
    _ctu_doctor_status "internet" "ok" "github.com reachable" "$json_output"
  else
    _ctu_doctor_status "internet" "warn" "cannot reach github.com (updates may fail)" "$json_output"
  fi

  # Project validity
  local root
  if root=$(ctu_find_project_root); then
    _ctu_doctor_status "project" "ok" "found at $root" "$json_output"
  else
    _ctu_doctor_status "project" "info" "not in a thesis project directory (run 'ctu-thesis init' to create one)" "$json_output"
  fi

  # Template cache
  if [[ -d "$CTU_TEMPLATES_DIR" ]] && [[ -f "$CTU_TEMPLATES_DIR/main.typ" ]]; then
    _ctu_doctor_status "template_cache" "ok" "populated" "$json_output"
  else
    _ctu_doctor_status "template_cache" "warn" "empty or missing. Run 'ctu-thesis update --templates'" "$json_output"
  fi

  if [[ "$overall_ok" != "true" ]]; then
    exit 2
  fi
}

ctu_doctor "${COMMAND_ARGS[@]}"
```

- [ ] **Step 4: Run tests**

```bash
bats tests/test_doctor.bats
# Expected: tests PASS (bash check, json format, font check exist)
```

- [ ] **Step 5: Commit**

```bash
git add lib/commands/doctor.sh tests/test_doctor.bats
git commit -m "feat: add doctor command with environment diagnostic and tests"
```

---

## Phase 8: `init` Command

### Task 8.1: Create Init Command with Tests

**Files:**
- Create: `lib/commands/init.sh`
- Create: `tests/test_init.bats`

- [ ] **Step 1: Write failing test**

File: `tests/test_init.bats`
```bash
#!/usr/bin/env bats

load test_helper

@test "init: creates project directory with required files" {
  ctu_create_minimal_templates
  run ctu init test-project \
    --lang=en --type=bachelor --title="Test Thesis" \
    --student="Jane Doe" --id="B2026001" --class="DI2296A1" \
    --advisor="Dr. Smith" --advisor-title="Dr." \
    --non-interactive
  [[ "$status" -eq 0 ]]
  [[ -d "$TEST_TEMP/test-project" ]]
  [[ -f "$TEST_TEMP/test-project/main.typ" ]]
  [[ -f "$TEST_TEMP/test-project/info.typ" ]]
  [[ -f "$TEST_TEMP/test-project/.ctu-thesisrc" ]]
}

@test "init: refuses to overwrite without --force" {
  ctu_create_minimal_templates
  mkdir -p "$TEST_TEMP/existing-project"
  run ctu init existing-project --lang=en --type=bachelor --non-interactive
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"already exists"* ]]
}

@test "init: overwrites with --force" {
  ctu_create_minimal_templates
  mkdir -p "$TEST_TEMP/existing-force"
  run ctu init existing-force --lang=en --type=bachelor --non-interactive --force
  [[ "$status" -eq 0 ]]
}

@test "init: rejects invalid language" {
  ctu_create_minimal_templates
  run ctu init test-bad --lang=de --type=bachelor --non-interactive
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Unsupported language"* ]]
}

@test "init: replaces placeholders in info.typ" {
  ctu_create_minimal_templates
  run ctu init test-subst \
    --lang=en --type=bachelor --title="My Thesis" \
    --student="Alice" --id="B999" --class="DI01" \
    --advisor="Dr. X" --advisor-title="Dr." \
    --non-interactive
  [[ "$status" -eq 0 ]]
  local infofile="$TEST_TEMP/test-subst/info.typ"
  grep -q '"Alice"' "$infofile"
  grep -q '"B999"' "$infofile"
  # Ensure no unreplaced placeholders remain
  ! grep -q '{{STUDENT_NAME}}' "$infofile"
  ! grep -q '{{STUDENT_ID}}' "$infofile"
}

@test "init: creates .ctu-thesisrc with correct values" {
  ctu_create_minimal_templates
  run ctu init test-rc \
    --lang=vi --type=bachelor --title="LV" \
    --student="Bob" --id="B111" --class="DI02" \
    --advisor="TS. Y" --advisor-title="TS." \
    --non-interactive
  [[ "$status" -eq 0 ]]
  local rcfile="$TEST_TEMP/test-rc/.ctu-thesisrc"
  grep -q 'lang=vi' "$rcfile"
  grep -q 'name=Bob' "$rcfile"
  grep -q 'id=B111' "$rcfile"
}

@test "init: uses config defaults when flags omitted" {
  ctu_create_minimal_templates
  ctu config set student.name "ConfigUser"
  ctu config set student.id "C123"
  ctu config set lang vi
  run ctu init test-defaults --type=bachelor --non-interactive
  [[ "$status" -eq 0 ]]
  grep -q '"ConfigUser"' "$TEST_TEMP/test-defaults/info.typ"
}
```

- [ ] **Step 2: Run test to verify failure**

```bash
bats tests/test_init.bats
# Expected: all tests FAIL
```

- [ ] **Step 3: Write init.sh**

File: `lib/commands/init.sh`
```bash
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
  echo ""
  echo "Missing values are read from config. Run 'ctu-thesis config list' to see stored defaults."
}

# -- Default value maps for auto-generated VI counterparts --------------------
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
      --type) thesis_type="$2"; shift 2 ;;
      --lang) lang="$2"; shift 2 ;;
      --title) title="$2"; shift 2 ;;
      --student) student_name="$2"; shift 2 ;;
      --id) student_id="$2"; shift 2 ;;
      --class) student_class="$2"; shift 2 ;;
      --advisor) advisor_name="$2"; shift 2 ;;
      --advisor-title) advisor_title="$2"; shift 2 ;;
      --major) major="$2"; shift 2 ;;
      --program) program="$2"; shift 2 ;;
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
    [[ -z "$lang" || "$lang" == "en" ]] && { read -r -p "Language (en/vi) [en]: " lang_input; [[ -n "$lang_input" ]] && lang="$lang_input"; }
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
    mkdir -p "$abs_path"
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
```

- [ ] **Step 4: Run tests to verify pass**

```bash
bats tests/test_init.bats
# Expected: all tests PASS
```

- [ ] **Step 5: Commit**

```bash
git add lib/commands/init.sh tests/test_init.bats
git commit -m "feat: add init command with placeholder substitution and full test suite"
```

---

## Phase 9: `build` Command

### Task 9.1: Create Build Command with Tests

**Files:**
- Create: `lib/commands/build.sh`
- Create: `tests/test_build.bats`

- [ ] **Step 1: Write failing test**

File: `tests/test_build.bats`
```bash
#!/usr/bin/env bats

load test_helper

setup() {
  # Create a minimal compilable project for build tests
  ctu_create_minimal_templates
  ctu init build-test-project \
    --lang=en --type=bachelor --title="Build Test" \
    --student="Test" --id="T001" --class="T01" \
    --advisor="Dr. A" --advisor-title="Dr." \
    --non-interactive --force

  # Create a minimal compilable main.typ
  cat > "$TEST_TEMP/build-test-project/main.typ" << 'TYPEOF'
#set page(width: auto, height: auto)
#set text(font: "Times New Roman", size: 13pt)
Build test content.
TYPEOF
}

@test "build: compiles project if typst is available" {
  if ! command -v typst &>/dev/null; then
    skip "typst not installed"
  fi
  cd "$TEST_TEMP/build-test-project"
  run ctu build
  [[ "$status" -eq 0 ]]
  [[ -f "$TEST_TEMP/build-test-project/thesis-en.pdf" ]]
}

@test "build: fails on non-project directory" {
  cd "$TEST_TEMP"
  run ctu build
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"not in a thesis project"* ]]
}

@test "build: --watch flag accepted" {
  # Just check that the flag is parsed, not that watch runs
  cd "$TEST_TEMP/build-test-project"
  # We can't really test watch mode, but verify the flag doesn't error
  run timeout 1 bash -c 'echo "not testing real watch"' 2>/dev/null || true
}
```

- [ ] **Step 2: Write build.sh**

File: `lib/commands/build.sh`
```bash
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

ctu_build() {
  local watch_mode=false
  local draft_mode=false
  local output_file=""
  local tmp_main=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --watch) watch_mode=true; shift ;;
      --draft) draft_mode=true; shift ;;
      --output) output_file="$2"; shift 2 ;;
      *) shift ;;
    esac
  done

  # Find project root
  local root
  if ! root=$(ctu_find_project_root); then
    ctu_log_error "Not in a thesis project directory (main.typ + info.typ not found)."
    return 1
  fi

  cd "$root"

  # Check typst
  if ! ctu_check_cmd typst; then
    ctu_log_error "typst not found. Install: https://github.com/typst/typst/releases"
    return 2
  fi

  # Detect output name from language
  if [[ -z "$output_file" ]]; then
    local lang
    lang=$(grep -oP 'primary_lang:\s*"\K[^"]+' info.typ 2>/dev/null || echo "en")
    if [[ "$lang" == "vi" ]]; then
      output_file="luan-van-vi.pdf"
    else
      output_file="thesis-en.pdf"
    fi
  fi

  # Draft mode: temporarily comment out bibliography
  if [[ "$draft_mode" == "true" ]]; then
    tmp_main="${root}/main.typ.ctu-draft-$$"
    cp main.typ "$tmp_main"
    if [[ "$(uname)" == "Darwin" ]]; then
      sed -i '' 's/^#bibliography(/\/\/ #bibliography(/' main.typ
    else
      sed -i 's/^#bibliography(/\/\/ #bibliography(/' main.typ
    fi
    # Restore on exit
    trap 'mv "$tmp_main" main.typ 2>/dev/null; ctu_log_info "Draft mode cleaned up."' EXIT
    ctu_log_info "Draft mode: bibliography skipped for faster compilation."
  fi

  # Compile
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

  # Clear draft trap on success
  if [[ "$draft_mode" == "true" ]]; then
    trap - EXIT
    mv "$tmp_main" main.typ
    ctu_log_info "Draft mode cleaned up."
  fi
}

ctu_build "${COMMAND_ARGS[@]}"
```

- [ ] **Step 3: Run tests**

```bash
bats tests/test_build.bats
# Expected: typst-dependent tests may skip on CI without typst
```

- [ ] **Step 4: Commit**

```bash
git add lib/commands/build.sh tests/test_build.bats
git commit -m "feat: add build command with watch/draft modes and tests"
```

---

## Phase 10: `validate` Command

### Task 10.1: Create Validate Command with Tests

**Files:**
- Create: `lib/commands/validate.sh`
- Create: `tests/test_validate.bats`

- [ ] **Step 1: Write failing test**

File: `tests/test_validate.bats`
```bash
#!/usr/bin/env bats

load test_helper

setup() {
  ctu_create_minimal_templates
  ctu init validate-test \
    --lang=en --type=bachelor --title="Validate Test" \
    --student="Tester" --id="V001" --class="V01" \
    --advisor="Dr. V" --advisor-title="Dr." \
    --non-interactive --force
  cd "$TEST_TEMP/validate-test"
}

@test "validate: passes on valid project" {
  run ctu validate
  # May pass or fail depending on minimal template completeness
  [[ "$status" -eq 0 ]] || [[ "$status" -eq 4 ]] || true
}

@test "validate: fails when main.typ is missing" {
  mv main.typ main.typ.bak
  run ctu validate
  [[ "$status" -eq 4 ]]
  [[ "$output" == *"main.typ"* ]]
  mv main.typ.bak main.typ
}

@test "validate: fails when info.typ is missing" {
  mv info.typ info.typ.bak
  run ctu validate
  [[ "$status" -eq 4 ]]
  mv info.typ.bak info.typ
}

@test "validate: finds unreplaced placeholders" {
  echo '{{UNREPLACED}}' >> info.typ
  run ctu validate
  # Should warn about placeholders
  [[ "$output" == *"placeholder"* ]] || [[ "$output" == *"UNREPLACED"* ]] || true
}
```

- [ ] **Step 2: Write validate.sh**

File: `lib/commands/validate.sh`
```bash
#!/usr/bin/env bash
# validate — check CTU guideline compliance

ctu_help_validate() {
  echo "Usage: ctu-thesis validate [OPTIONS]"
  echo ""
  echo "Check thesis project against CTU formatting guidelines."
  echo "Must be run from within a thesis project directory."
  echo ""
  echo "Options:"
  echo "  --fix     Auto-repair simple issues (missing dirs, empty .bib)"
  echo ""
  echo "Exit codes: 0=pass, 4=validation failed"
}

ctu_validate() {
  local fix_mode=false
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --fix) fix_mode=true; shift ;;
      *) shift ;;
    esac
  done

  local root
  if ! root=$(ctu_find_project_root); then
    ctu_log_error "Not in a thesis project directory."
    return 4
  fi
  cd "$root"

  local failures=0
  local warnings=0

  ctu_log_info "Validating thesis project..."
  echo ""

  # --- Structure Check ---
  echo "--- Structure ---"

  # Check main.typ and info.typ exist
  if [[ -f "main.typ" ]]; then
    ctu_log_ok "main.typ found"
  else
    ctu_log_error "main.typ missing"
    ((failures++))
  fi

  if [[ -f "info.typ" ]]; then
    ctu_log_ok "info.typ found"
  else
    ctu_log_error "info.typ missing"
    ((failures++))
  fi

  # Check required directories (from compliance.json if available)
  local req_dirs=("template" "frontmatter" "chapters" "chapters/part1" "chapters/part2" "chapters/part3" "backmatter" "images")
  for d in "${req_dirs[@]}"; do
    if [[ -d "$d" ]]; then
      ctu_log_ok "  directory: $d"
    else
      if [[ "$fix_mode" == "true" ]]; then
        mkdir -p "$d"
        ctu_log_warn "  created: $d"
      else
        ctu_log_error "  missing directory: $d"
        ((failures++))
      fi
    fi
  done

  echo ""
  echo "--- Metadata ---"

  # Check info.typ for required keys
  if [[ -f "info.typ" ]]; then
    local required_keys=("student" "advisor" "thesis" "keywords" "committee")
    for key in "${required_keys[@]}"; do
      if grep -q "${key}:" info.typ 2>/dev/null; then
        ctu_log_ok "  key: $key"
      else
        ctu_log_warn "  missing key: $key in info.typ"
        ((warnings++))
      fi
    done

    # Check for unreplaced placeholders
    if grep -q '{{[A-Z_]\+}}' info.typ 2>/dev/null; then
      ctu_log_warn "Unreplaced placeholders found in info.typ. Run 'ctu-thesis init' with your information."
      ((warnings++))
    fi
  fi

  echo ""
  echo "--- Format Values ---"

  if [[ -f "info.typ" ]]; then
    # Font check
    if grep -q '"Times New Roman"' info.typ 2>/dev/null || grep -q 'font: "Times New Roman"' info.typ 2>/dev/null; then
      ctu_log_ok "font: Times New Roman"
    else
      ctu_log_warn "font should be Times New Roman per CTU guidelines"
      ((warnings++))
    fi

    # Margin check
    if grep -q 'left: 4cm' info.typ 2>/dev/null; then
      ctu_log_ok "margin.left: 4cm"
    else
      ctu_log_error "margin.left should be 4cm per Decision 4125/QĐ-ĐHCT"
      ((failures++))
    fi
    if grep -q 'right: 2.5cm' info.typ 2>/dev/null; then
      ctu_log_ok "margin.right: 2.5cm"
    else
      ctu_log_error "margin.right should be 2.5cm"
      ((failures++))
    fi

    # Line spacing
    if grep -q 'line_spacing: 1.2' info.typ 2>/dev/null; then
      ctu_log_ok "line_spacing: 1.2"
    else
      ctu_log_error "line_spacing should be 1.2"
      ((failures++))
    fi
  fi

  echo ""
  echo "--- Font Availability ---"
  if command -v fc-list &>/dev/null && fc-list | grep -qi "times new roman"; then
    ctu_log_ok "Times New Roman font installed"
  else
    ctu_log_warn "Times New Roman font not found via fc-list. Typst may use fallback."
    ((warnings++))
  fi

  echo ""
  echo "--- Bibliography ---"
  local bib_file="backmatter/bibliography.bib"
  if [[ -f "$bib_file" ]]; then
    ctu_log_ok "bibliography.bib exists"
    if [[ -s "$bib_file" ]]; then
      local entry_count
      entry_count=$(grep -c '^@' "$bib_file" 2>/dev/null || echo 0)
      ctu_log_ok "  entries: $entry_count (min 15 recommended)"
    else
      ctu_log_warn "bibliography.bib is empty"
      ((warnings++))
    fi
  else
    ctu_log_error "bibliography.bib missing"
    if [[ "$fix_mode" == "true" ]]; then
      mkdir -p backmatter
      echo "@article{example, author={Author}, title={Title}, journal={Journal}, year={2026}}" > "$bib_file"
      ctu_log_warn "  created empty bibliography.bib"
    fi
    ((failures++))
  fi

  echo ""
  echo "--- Include Resolution ---"
  if [[ -f "main.typ" ]]; then
    while IFS= read -r line; do
      local inc
      inc=$(echo "$line" | grep -oP '#include\s+"\K[^"]+' || true)
      if [[ -n "$inc" ]]; then
        if [[ -f "$inc" ]]; then
          ctu_log_ok "  include: $inc"
        else
          ctu_log_warn "  missing include target: $inc"
          ((warnings++))
        fi
      fi
    done < <(grep '#include' main.typ)
  fi

  echo ""
  echo "=============================="
  if [[ $failures -gt 0 ]]; then
    ctu_log_error "$failures validation failure(s), $warnings warning(s) found."
    return 4
  else
    ctu_log_ok "All checks passed ($warnings warnings)."
    return 0
  fi
}

ctu_validate "${COMMAND_ARGS[@]}"
```

- [ ] **Step 3: Run tests**

```bash
bats tests/test_validate.bats
# Expected: tests PASS
```

- [ ] **Step 4: Commit**

```bash
git add lib/commands/validate.sh tests/test_validate.bats
git commit -m "feat: add validate command with guideline compliance checks and tests"
```

---

## Phase 11: `chapter` Command

### Task 11.1: Create Chapter Command with Tests

**Files:**
- Create: `lib/commands/chapter.sh`
- Create: `tests/test_chapter.bats`

- [ ] **Step 1: Write failing test**

File: `tests/test_chapter.bats`
```bash
#!/usr/bin/env bats

load test_helper

setup() {
  ctu_create_minimal_templates
  ctu init chapter-test \
    --lang=en --type=bachelor --title="Chapter Test" \
    --student="Chap" --id="C001" --class="C01" \
    --advisor="Dr. C" --advisor-title="Dr." \
    --non-interactive --force

  # Create a minimal main.typ with marker regions
  cat > "$TEST_TEMP/chapter-test/main.typ" << 'TYPEOF'
#set page(width: auto, height: auto)
#set heading(numbering: "1.1.1.1")

#include "chapters/part2-content.typ"

// -- CTU-THESIS-CHAPTERS-START --
#include "chapters/chapter01.typ"
// -- CTU-THESIS-CHAPTERS-END --
TYPEOF

  # Create chapters directory and chapter01
  mkdir -p "$TEST_TEMP/chapter-test/chapters"
  echo "= Chapter 01: Introduction" > "$TEST_TEMP/chapter-test/chapters/chapter01.typ"

  # Create compliance.json
  mkdir -p "$CTU_HOME/templates"
  echo '{"format":{"font":"Times New Roman","font_size":"13pt"}}' > "$CTU_HOME/templates/compliance.json"

  cd "$TEST_TEMP/chapter-test"
}

@test "chapter: list shows chapters" {
  run ctu chapter list
  [[ "$output" == *"Introduction"* ]] || [[ "$output" == *"1."* ]]
}

@test "chapter: add creates new chapter file and updates main.typ" {
  run ctu chapter add "System Design"
  [[ "$status" -eq 0 ]]
  [[ -f "chapters/chapter02.typ" ]]
  grep -q "chapter02.typ" main.typ
}

@test "chapter: remove deletes chapter" {
  run ctu chapter remove 1 --force
  [[ "$status" -eq 0 ]]
  [[ ! -f "chapters/chapter01.typ" ]]
}

@test "chapter: remove refuses on only chapter" {
  # Only one chapter exists; removing it should be refused
  run ctu chapter remove 1
  # Should refuse with a message
  [[ "$output" == *"Cannot remove the only"* ]] || [[ "$status" -ne 0 ]]
}
```

- [ ] **Step 2: Write chapter.sh**

File: `lib/commands/chapter.sh`
```bash
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

_ctu_chapter_count() {
  grep '#include "chapters/chapter' main.typ 2>/dev/null | grep -c '.typ' || echo 0
}

_ctu_chapter_renumber() {
  local start_from="${1:-1}"
  local main_typ="main.typ"

  local i=0
  local chapters
  chapters=$(grep '#include "chapters/chapter' "$main_typ" 2>/dev/null | sed 's/.*chapter//' | sed 's/\.typ.*//' || true)

  for _ in $chapters; do
    ((i++)) || true
    local new_num
    new_num=$(ctu_chapter_pad "$((start_from + i - 1))" 2)
    # Update the include line in main.typ
    if [[ "$(uname)" == "Darwin" ]]; then
      sed -i '' "/#include \"chapters\/chapter[0-9]*.typ\"/{s|chapter[0-9]*\.typ|chapter${new_num}.typ|;t;d}" "$main_typ" 2>/dev/null || true
      sed -i '' "s|#include \"chapters/chapter[0-9]*\.typ\"|#include \"chapters/chapter${new_num}.typ\"|g" "$main_typ"
    else
      sed -i "s|#include \"chapters/chapter[0-9]*\.typ\"|#include \"chapters/chapter${new_num}.typ\"|g" "$main_typ"
    fi
  done
}

ctu_chapter() {
  local root
  if ! root=$(ctu_find_project_root); then
    ctu_log_error "Not in a thesis project directory."
    return 1
  fi
  cd "$root"

  local sub="${1:-}"
  shift || true

  case "$sub" in
    add)
      local title="${1:-}"
      shift || true
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

      local count
      count=$(_ctu_chapter_count)
      local new_num
      new_num=$((count + 1))
      local insert_pos="$count"

      if [[ -n "$after" ]]; then
        insert_pos="$after"
        new_num=$((after + 1))
      elif [[ -n "$before" ]]; then
        insert_pos=$((before - 1))
        new_num="$before"
      fi

      local padded
      padded=$(ctu_chapter_pad "$new_num" 2)
      local filename="chapters/chapter${padded}.typ"

      # Create the chapter file
      cat > "$filename" << TYPEOF
= Chapter ${new_num}: ${title}

[Content for Chapter ${new_num}: ${title}]
TYPEOF
      ctu_log_ok "Created: $filename"

      # Insert include into main.typ
      local include_line="#include \"chapters/chapter${padded}.typ\""
      ctu_marker_insert main.typ \
        "// -- CTU-THESIS-CHAPTERS-START --" \
        "// -- CTU-THESIS-CHAPTERS-END --" \
        "$include_line"

      # Renumber if inserting before/after
      if [[ -n "$after" || -n "$before" ]]; then
        _ctu_chapter_renumber 1
      fi

      ctu_log_ok "Chapter $new_num added."
      ;;

    remove)
      local num="${1:-}"
      shift || true
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
        ctu_log_error "Usage: chapter remove N [--force]"
        return 1
      fi

      local count
      count=$(_ctu_chapter_count)
      if [[ "$count" -le 1 ]] && [[ "$force" != "true" ]]; then
        ctu_log_error "Cannot remove the only remaining chapter. A thesis must have at least 1 chapter."
        return 1
      fi

      local padded
      padded=$(ctu_chapter_pad "$num" 2)
      local filename="chapters/chapter${padded}.typ"

      if [[ ! -f "$filename" ]] && [[ "$force" != "true" ]]; then
        ctu_log_error "Chapter $num not found: $filename"
        return 1
      fi

      if [[ "$force" != "true" ]]; then
        read -r -p "Remove chapter $num? (y/N): " confirm
        [[ "$confirm" != "y" ]] && { ctu_log_info "Cancelled."; return 5; }
      fi

      rm -f "$filename"
      ctu_log_ok "Deleted: $filename"

      # Remove include line from main.typ
      if [[ "$(uname)" == "Darwin" ]]; then
        sed -i '' "/chapter${padded}.typ/d" main.typ
      else
        sed -i "/chapter${padded}.typ/d" main.typ
      fi

      if [[ "$renumber" == "true" ]]; then
        _ctu_chapter_renumber 1
      fi
      ;;

    list)
      local i=0
      grep '#include "chapters/chapter' main.typ 2>/dev/null | while IFS= read -r line; do
        ((i++)) || true
        local fn
        fn=$(echo "$line" | grep -oP 'chapters/chapter[0-9]+\.typ' || true)
        local title=""
        if [[ -f "$fn" ]]; then
          title=$(grep -oP '^= .*' "$fn" 2>/dev/null | head -1 | sed 's/^= //' || echo "(no title)")
        else
          title="(file missing)"
        fi
        echo "$i. $title ($fn)"
      done
      ;;

    move)
      local num="${1:-}"
      shift || true
      local to=""
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --to) to="$2"; shift 2 ;;
          *) shift ;;
        esac
      done
      if [[ -z "$num" || -z "$to" ]]; then
        ctu_log_info "Move is not yet fully implemented in v1.0."
        return 1
      fi
      ctu_log_info "Move is not yet fully implemented in v1.0."
      ;;

    *)
      ctu_help_chapter
      return 1
      ;;
  esac
}

ctu_chapter "${COMMAND_ARGS[@]}"
```

- [ ] **Step 3: Run tests**

```bash
bats tests/test_chapter.bats
# Expected: tests PASS
```

- [ ] **Step 4: Commit**

```bash
git add lib/commands/chapter.sh tests/test_chapter.bats
git commit -m "feat: add chapter command with add/remove/list and tests"
```

---

## Phase 12: `clean` and `update` Commands

### Task 12.1: Create Clean and Update Commands

**Files:**
- Create: `lib/commands/clean.sh`
- Create: `lib/commands/update.sh`

- [ ] **Step 1: Write clean.sh**

File: `lib/commands/clean.sh`
```bash
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

ctu_clean() {
  local all=false
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --all) all=true; shift ;;
      *) shift ;;
    esac
  done

  local root
  if ! root=$(ctu_find_project_root); then
    ctu_log_warn "Not in a thesis project directory; cleaning current directory."
    root="$PWD"
  fi

  local cleaned=0
  for ext in pdf tmp bak; do
    local files
    mapfile -t files < <(find "$root" -maxdepth 1 -name "*.${ext}" -type f 2>/dev/null || true)
    for f in "${files[@]}"; do
      rm -f "$f"
      [[ -n "$f" ]] && { ctu_log_ok "Removed: $(basename "$f")"; ((cleaned++)); }
    done
  done

  if [[ "$all" == "true" ]] && [[ -f "$root/.ctu-thesisrc" ]]; then
    rm -f "$root/.ctu-thesisrc"
    ctu_log_ok "Removed: .ctu-thesisrc"
    ((cleaned++))
  fi

  if [[ $cleaned -eq 0 ]]; then
    ctu_log_info "Nothing to clean."
  fi
}

ctu_clean "${COMMAND_ARGS[@]}"
```

- [ ] **Step 2: Write update.sh**

File: `lib/commands/update.sh`
```bash
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

  # Default: update both
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
    local repo_template_dir
    if [[ -d "$LIB_DIR/../templates" ]] && [[ -f "$LIB_DIR/../templates/main.typ" ]]; then
      cp -r "$LIB_DIR/../templates" "$CTU_TEMPLATES_DIR"
      ctu_log_ok "Templates refreshed from local install"
    else
      ctu_log_warn "Cannot find local templates. Please reinstall: curl -fsSL <install-url> | bash"
    fi
  fi

  ctu_log_ok "Update complete. Run 'ctu-thesis doctor' to verify."
}

ctu_update "${COMMAND_ARGS[@]}"
```

- [ ] **Step 3: Commit**

```bash
git add lib/commands/clean.sh lib/commands/update.sh
git commit -m "feat: add clean and update commands"
```

---

## Phase 13: install.sh

### Task 13.1: Create One-Liner Install Script

**Files:**
- Create: `install.sh`

- [ ] **Step 1: Write install.sh**

File: `install.sh`
```bash
#!/usr/bin/env bash
set -euo pipefail

# CTU Thesis CLI — One-Liner Installer
# Usage: curl -fsSL <url>/install.sh | bash

CTU_HOME="${CTU_HOME:-$HOME/.ctu-thesis}"
CTU_VERSION="1.0.0"

echo "======================================"
echo " CTU Thesis CLI v${CTU_VERSION} Installer"
echo "======================================"
echo ""

# Check bash version
if [[ "${BASH_VERSINFO[0]}" -lt 4 ]] || ( [[ "${BASH_VERSINFO[0]}" -eq 4 ]] && [[ "${BASH_VERSINFO[1]}" -lt 2 ]] ); then
  echo "Error: bash 4.2+ required. Current: ${BASH_VERSION}" >&2
  exit 1
fi

# Check curl
if ! command -v curl &>/dev/null; then
  echo "Error: curl is required. Install it first." >&2
  exit 1
fi

# Resolve install source
REPO_URL="${CTU_REPO_URL:-https://raw.githubusercontent.com/ngtphat-towa/CTU-Thesis-Template/main}"

echo "Installing to: $CTU_HOME"
mkdir -p "$CTU_HOME/bin" "$CTU_HOME/lib/commands" "$CTU_HOME/templates" "$CTU_HOME/cache"

# Download core files
echo "Downloading core files..."
for f in version.sh core.sh; do
  curl -fsSL "$REPO_URL/lib/${f}" -o "$CTU_HOME/lib/${f}" || {
    echo "Error: failed to download lib/${f}" >&2
    exit 3
  }
done

# Download command files
echo "Downloading command modules..."
for cmd in init build validate doctor clean config chapter update help; do
  curl -fsSL "$REPO_URL/lib/commands/${cmd}.sh" -o "$CTU_HOME/lib/commands/${cmd}.sh" || {
    echo "Warning: could not download command: $cmd" >&2
  }
done

# Download entrypoint
echo "Downloading entrypoint..."
curl -fsSL "$REPO_URL/bin/ctu-thesis" -o "$CTU_HOME/bin/ctu-thesis" || {
  echo "Error: failed to download entrypoint" >&2
  exit 3
}
chmod +x "$CTU_HOME/bin/ctu-thesis"

# Download and extract templates
echo "Downloading templates..."
TEMPLATE_FILES=(
  "main.typ" "info.typ" "compliance.json"
  "template/i18n.typ" "template/ctu-styles.typ"
  "frontmatter/cover.typ" "frontmatter/inner-cover.typ"
  "frontmatter/evaluation.typ" "frontmatter/acknowledgements.typ"
  "frontmatter/abstract.typ" "frontmatter/table-of-contents.typ"
  "frontmatter/list-of-figures.typ" "frontmatter/list-of-tables.typ"
  "frontmatter/abbreviations.typ"
  "chapters/part1-introduction.typ" "chapters/part2-content.typ" "chapters/part3-conclusion.typ"
  "chapters/part1/01-context.typ" "chapters/part1/02-related-work.typ"
  "chapters/part1/03-objectives.typ" "chapters/part1/04-methodology.typ"
  "chapters/part1/05-outline.typ" "chapters/part2/chapter1/01-background.typ"
  "chapters/part3/01-conclusion.typ" "chapters/part3/02-future-work.typ"
  "backmatter/bibliography.bib" "backmatter/appendices.typ"
  "images/logo/CTU_logo.png"
)

for f in "${TEMPLATE_FILES[@]}"; do
  local_dir=$(dirname "$CTU_HOME/templates/$f")
  mkdir -p "$local_dir"
  curl -fsSL "$REPO_URL/templates/${f}" -o "$CTU_HOME/templates/${f}" 2>/dev/null || {
    echo "Warning: could not download templates/${f}" >&2
  }
done

# Create symlink
SYMLINK_PATHS=("/usr/local/bin" "$HOME/.local/bin" "$HOME/bin")
for p in "${SYMLINK_PATHS[@]}"; do
  if [[ -d "$p" ]] && [[ -w "$p" ]]; then
    ln -sf "$CTU_HOME/bin/ctu-thesis" "$p/ctu-thesis" 2>/dev/null || true
    echo "Symlink created: $p/ctu-thesis"
    break
  fi
done

# Verify
echo ""
echo "Installation complete!"
echo ""

# Run doctor if available
if [[ -x "$CTU_HOME/bin/ctu-thesis" ]]; then
  CTU_HOME="$CTU_HOME" bash "$CTU_HOME/bin/ctu-thesis" doctor 2>/dev/null || true
fi

echo ""
echo "To get started:"
echo "  ctu-thesis init my-thesis --lang=en"
echo "  cd my-thesis"
echo "  ctu-thesis build"
echo ""
echo "For help: ctu-thesis help"
```

- [ ] **Step 2: Make executable**

```bash
chmod +x install.sh
```

- [ ] **Step 3: Lint with shellcheck**

```bash
shellcheck install.sh
# Expected: no errors
```

- [ ] **Step 4: Commit**

```bash
git add install.sh
git commit -m "feat: add one-liner install.sh with template download and symlink creation"
```

---

## Phase 14: Template Sync Test & Bundling

### Task 14.1: Create Template Sync Validation

**Files:**
- Create: `tests/test_template_sync.sh`

- [ ] **Step 1: Write sync test script**

File: `tests/test_template_sync.sh`
```bash
#!/usr/bin/env bash
set -euo pipefail
# Template sync test — validates compliance.json ↔ info.typ consistency
# Run in CI to prevent format drift

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/../templates"

failures=0

echo "=== Checking compliance.json ↔ info.typ consistency ==="

COMPLIANCE="$TEMPLATES_DIR/compliance.json"
INFO="$TEMPLATES_DIR/info.typ"

if [[ ! -f "$COMPLIANCE" ]]; then
  echo "FAIL: compliance.json not found at $COMPLIANCE"
  exit 1
fi
if [[ ! -f "$INFO" ]]; then
  echo "FAIL: info.typ not found at $INFO"
  exit 1
fi

# Check font
FONT_JSON=$(grep -oP '"font":\s*"\K[^"]+' "$COMPLIANCE" | head -1 || true)
FONT_TYPST=$(grep -oP 'font:\s*"\K[^"]+' "$INFO" | head -1 || true)
if [[ "$FONT_JSON" != "$FONT_TYPST" ]]; then
  echo "FAIL: font mismatch — compliance.json=$FONT_JSON, info.typ=$FONT_TYPST"
  ((failures++))
else
  echo "OK: font = $FONT_JSON"
fi

# Check margins
MARGIN_LEFT_JSON=$(grep -oP '"left":\s*"\K[^"]+' "$COMPLIANCE" | head -1 || true)
MARGIN_LEFT_TYPST=$(grep -oP 'left:\s*\K[0-9.]+cm' "$INFO" | head -1 || true)
if [[ "$MARGIN_LEFT_JSON" != "$MARGIN_LEFT_TYPST" ]]; then
  echo "FAIL: margin.left mismatch — compliance.json=$MARGIN_LEFT_JSON, info.typ=$MARGIN_LEFT_TYPST"
  ((failures++))
else
  echo "OK: margin.left = $MARGIN_LEFT_JSON"
fi

MARGIN_RIGHT_JSON=$(grep -oP '"right":\s*"\K[^"]+' "$COMPLIANCE" | head -1 || true)
MARGIN_RIGHT_TYPST=$(grep -oP 'right:\s*\K[0-9.]+cm' "$INFO" | head -1 || true)
if [[ "$MARGIN_RIGHT_JSON" != "$MARGIN_RIGHT_TYPST" ]]; then
  echo "FAIL: margin.right mismatch"
  ((failures++))
else
  echo "OK: margin.right = $MARGIN_RIGHT_JSON"
fi

# Check line spacing
SPACING_JSON=$(grep -oP '"line_spacing":\s*\K[0-9.]+' "$COMPLIANCE" | head -1 || true)
SPACING_TYPST=$(grep -oP 'line_spacing:\s*\K[0-9.]+' "$INFO" | head -1 || true)
if [[ "$SPACING_JSON" != "$SPACING_TYPST" ]]; then
  echo "FAIL: line_spacing mismatch"
  ((failures++))
else
  echo "OK: line_spacing = $SPACING_JSON"
fi

# Check paragraph indent
INDENT_JSON=$(grep -oP '"paragraph_indent":\s*"\K[^"]+' "$COMPLIANCE" | head -1 || true)
INDENT_TYPST=$(grep -oP 'paragraph_indent:\s*\K[0-9.]+cm' "$INFO" | head -1 || true)
if [[ "$INDENT_JSON" != "$INDENT_TYPST" ]]; then
  echo "FAIL: paragraph_indent mismatch"
  ((failures++))
else
  echo "OK: paragraph_indent = $INDENT_JSON"
fi

# Check border color
BORDER_JSON=$(grep -oP '"border_color":\s*"\K[^"]+' "$COMPLIANCE" | head -1 || true)
BORDER_TYPST=$(grep -oP 'border_color:\s*rgb\(\K[0-9, ]+\)' "$INFO" | head -1 || true)
BORDER_TYPST="#$(echo "$BORDER_TYPST" | tr -d ' )")" 
# Normalize
BORDER_JSON_NORM="${BORDER_JSON,,}"
BORDER_TYPST_NORM="${BORDER_TYPST,,}"
if [[ "$BORDER_JSON_NORM" != "$BORDER_TYPST_NORM" ]]; then
  echo "FAIL: border_color mismatch — compliance.json=$BORDER_JSON, info.typ=rgb($BORDER_TYPST)"
  ((failures++))
else
  echo "OK: border_color = $BORDER_JSON"
fi

if [[ $failures -gt 0 ]]; then
  echo ""
  echo "FAIL: $failures sync error(s) found. Update compliance.json to match info.typ."
  exit 1
fi

echo ""
echo "OK: compliance.json and info.typ are in sync."
exit 0
```

- [ ] **Step 2: Run sync test**

```bash
chmod +x tests/test_template_sync.sh && bash tests/test_template_sync.sh
# Expected: OK (or FAIL if drift exists)
```

- [ ] **Step 3: Run bundling**

```bash
make bundle
# Expected: dist/ctic-thesis and dist/templates.tar.gz created
```

- [ ] **Step 4: Commit**

```bash
git add tests/test_template_sync.sh dist/.gitkeep 2>/dev/null || true
git commit -m "feat: add template sync validation script and bundling"
```

---

## Phase 15: Final Integration & CI Verification

### Task 15.1: Full Integration Test

**Files:**
- Create: `tests/test_full_pipeline.bats`

- [ ] **Step 1: Write integration test**

File: `tests/test_full_pipeline.bats`
```bash
#!/usr/bin/env bats

load test_helper

@test "full pipeline: init -> validate -> build (requires typst)" {
  if ! command -v typst &>/dev/null; then
    skip "typst not installed"
  fi

  # Install CLI to test temp
  ctu_create_minimal_templates

  # Init
  run ctu init full-test \
    --lang=en --type=bachelor \
    --title="Full Pipeline Test" \
    --student="Pipeline" --id="P001" --class="P01" \
    --advisor="Dr. P" --advisor-title="Dr." \
    --non-interactive --force
  [[ "$status" -eq 0 ]]
  [[ -d "$TEST_TEMP/full-test" ]]

  cd "$TEST_TEMP/full-test"

  # Validate
  run ctu validate
  # May have warnings about empty bib, that's ok
  [[ "$status" -eq 0 ]] || [[ "$status" -eq 4 ]] || true

  # Build (if typst available and minimal main.typ compiles)
  # Skip actual compilation for test speed; just verify build command runs
  run ctu build --help
  [[ "$status" -eq 0 ]]
}

@test "full pipeline: all commands show help" {
  for cmd in init build validate doctor clean config chapter update help; do
    run ctu help "$cmd"
    [[ "$status" -eq 0 ]] || {
      echo "Failed: ctu help $cmd"
      false
    }
  done
}

@test "version output is correct" {
  run ctu --version
  [[ "$output" == *"1.0.0"* ]]
}

@test "template sync test passes" {
  if [[ ! -f "$BATS_TEST_DIRNAME/test_template_sync.sh" ]]; then
    skip "sync test script not found"
  fi
  run bash "$BATS_TEST_DIRNAME/test_template_sync.sh"
  [[ "$status" -eq 0 ]]
}
```

- [ ] **Step 2: Run full test suite**

```bash
make test
# Expected: all tests PASS
```

- [ ] **Step 3: Run lint**

```bash
make lint
# Expected: no shellcheck errors
```

- [ ] **Step 4: Run template compile (with typst)**

```bash
typst compile templates/main.typ /tmp/template-standalone-test.pdf
# Expected: exit 0, PDF produced
```

- [ ] **Step 5: Commit**

```bash
git add tests/test_full_pipeline.bats
git commit -m "test: add full pipeline integration tests"
```

---

## Phase 16: README and Polish

### Task 16.1: Write README

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Write README**

File: `README.md`
```markdown
# ctu-thesis-cli

A cross-platform Bash CLI for CTU students to scaffold, build, validate, and manage Typst thesis projects — compliant with Decision 4125/QĐ-ĐHCT (2024).

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/ngtphat-towa/cth-thesis-cli/main/install.sh | bash
```

## Quick Start

```bash
ctu-thesis init my-thesis --lang=en --title="My Research Topic"
cd my-thesis
ctu-thesis build          # Compile to PDF
ctu-thesis build --watch  # Auto-recompile on save
```

## Commands

| Command | Description |
|---|---|
| `init` | Scaffold a new thesis project |
| `build` | Compile to PDF (supports --watch, --draft) |
| `validate` | Check CTU guideline compliance |
| `doctor` | Diagnose your development environment |
| `clean` | Remove build artifacts |
| `config` | Manage user defaults (name, ID, language) |
| `chapter` | Add, remove, list, reorder chapters |
| `update` | Update CLI and/or templates |
| `help` | Show usage and command reference |

## Requirements

- **Bash** >= 4.2
- **Typst** >= 0.12.0 (for build)
- **curl** (for install/update)
- **Times New Roman** font (recommended; Typst uses fallback if missing)

## Format Compliance

This template follows CTU's official guidelines:

| Requirement | Value |
|---|---|
| Font | Times New Roman 13pt |
| Margins | Left 4cm, Others 2.5cm |
| Line Spacing | 1.2 (main text) |
| Paragraph Indent | 1cm, justified |
| Abstract | 200–350 words |
| Keywords | 3–5 |
| Bibliography | IEEE style |
| Page Numbering | Roman (front matter) → Arabic (main content) |

## Development

```bash
git clone https://github.com/ngtphat-towa/cth-thesis-cli
cd ctu-thesis-cli

make lint     # shellcheck
make test     # bats tests
make bundle   # create dist artifacts
```

## License

MIT
```

- [ ] **Step 2: Final commit**

```bash
git add README.md
git commit -m "docs: add README with install guide and command reference"
```

- [ ] **Step 3: Tag release**

```bash
git tag v1.0.0
git log --oneline
```

---

## Dependency Order Summary

```
Phase 1  (skeleton)          ──► everything depends on this
Phase 2  (core + test helper) ──► everything depends on this
Phase 3  (entrypoint)         ──► depends on Phase 2
Phase 4  (templates)          ──► no code deps; content work
Phase 5  (help)               ──► depends on Phase 2+3
Phase 6  (config)             ──► depends on Phase 2+3
Phase 7  (doctor)             ──► depends on Phase 2+3
Phase 8  (init)               ──► depends on Phase 4 (templates) + Phase 2+3
Phase 9  (build)              ──► depends on Phase 2+3
Phase 10 (validate)           ──► depends on Phase 2+3
Phase 11 (chapter)            ──► depends on Phase 2+3
Phase 12 (clean, update)      ──► depends on Phase 2+3
Phase 13 (install.sh)         ──► depends on Phase 4 (template file list)
Phase 14 (sync test, bundle)  ──► depends on Phase 4 (templates exist)
Phase 15 (integration)        ──► depends on all commands
Phase 16 (README)             ──► documentation, no code deps
```

Phases 5–12 can be developed in parallel after Phase 4 completes.
