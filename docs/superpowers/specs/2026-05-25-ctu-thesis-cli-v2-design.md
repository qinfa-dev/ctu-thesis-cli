---
title: CTU Thesis CLI v2.0 — Design Specification
version: 1.0
date_created: 2026-05-25
last_updated: 2026-05-25
owner: qingfa
tags: [cli, bash, typst, thesis, ctu, tool, design, specification]
---

# Introduction

This specification defines the design, architecture, and requirements for **ctu-thesis-cli v2.0** — a cross-platform Bash CLI tool that scaffolds, builds, validates, and manages Typst-based graduation thesis projects for Can Tho University (CTU) students. The primary audience is the College of Information and Communication Technology (CICT), specifically the CT216H project course track (undergraduate bachelor thesis).

The v2.0 is a ground-up rebuild of the earlier `_resys.ctu.template/` experiment, discarding its architecture in favor of a cleaner design with co-located template files, full compilable project generation, and strict guideline compliance validation.

---

## 1. Purpose & Scope

### Purpose

Provide CTU students with a single CLI tool — analogous to Angular CLI or Create React App — that:
1. Generates a **complete, independently compilable** Typst thesis project in seconds
2. Validates the generated project against official CTU formatting guidelines (Decision 4125/QĐ-ĐHCT, 2024)
3. Diagnoses the user's environment for missing dependencies
4. Manages chapters and project metadata throughout the writing lifecycle

### Scope

- **In scope (v1.0)**: init, build, validate, doctor, clean, config, chapter, update, help (9 commands)
- **In scope**: bachelor (undergraduate) thesis template (`--type=bachelor`) with English and Vietnamese language variants (`--lang=en|vi`)
- **Out of scope for v1.0**: master's thesis, PhD dissertation, appendix/figure/table stub commands, export/status/uninstall
- **Platform target**: Linux and macOS (bash 4.2+); Windows via WSL/Git Bash
- **Template format**: Typst (`main.typ` as root document)

### Success Criteria

- A first-time user can run `ctu-thesis init my-thesis && cd my-thesis && ctu-thesis build` and get a valid PDF with no errors
- `ctu-thesis validate` catches format-guideline violations before advisor review
- `ctu-thesis doctor` provides actionable fix hints on any environment missing dependencies
- CI pipeline blocks any PR that introduces drift between `info.typ` and `compliance.json`

---

## 2. Definitions

| Term | Definition |
|---|---|
| **CTU** | Can Tho University, Vietnam |
| **CICT** | College of Information and Communication Technology |
| **Typst** | A modern, high-performance typesetting system and PDF compiler (v0.12.0+) |
| **Decision 4125/QĐ-ĐHCT** | Official CTU regulation governing thesis formatting (2024) |
| **Placeholder** | A `{{VARIABLE}}` marker in template `.typ` files replaced by `init` with user-provided values |
| **CTU_HOME** | `~/.ctu-thesis/` — the installation directory for CLI binaries, libraries, and cached templates |
| **compliance.json** | Mirror of `info.typ` format values, read by `validate` and `doctor` for guideline checks |
| **Marker region** | Comment-delimited section in `main.typ` managed by `chapter` command |
| **bats** | Bash Automated Testing System — the test framework for this project |
| **TNR** | Times New Roman — the required font per CTU guidelines |

---

## 3. Requirements, Constraints & Guidelines

### Functional Requirements

- **REQ-001**: `init` shall generate a complete, compilable Typst thesis project from the co-located `templates/` directory, replacing all `{{PLACEHOLDER}}` variables with user-provided values.
- **REQ-002**: `build` shall compile the project to PDF using `typst compile`, auto-detecting the output filename from the project language.
- **REQ-003**: `build --draft` shall temporarily omit the bibliography to enable faster compilation.
- **REQ-004**: `build --watch` shall recompile on file changes using `typst watch`.
- **REQ-005**: `validate` shall check the project structure, metadata completeness, format compliance (font, margins, spacing), include resolution, bibliography existence, and abstract word count.
- **REQ-006**: `validate --fix` shall auto-repair simple issues (missing directories, empty `.bib` file, unreplaced placeholders).
- **REQ-007**: `doctor` shall diagnose bash version, typst installation, git, Times New Roman font availability, internet connectivity, project validity, and template cache status.
- **REQ-008**: `doctor --json` shall output machine-readable JSON for IDE/tool integration.
- **REQ-009**: `clean` shall remove build artifacts (`*.pdf`, `*.tmp`, `*.bak`); `--all` shall also remove `.ctu-thesisrc`.
- **REQ-010**: `config` shall support `set`, `get`, `list`, and `unset` operations on key-value pairs in `~/.ctu-thesis/config`.
- **REQ-011**: `init` shall read `~/.ctu-thesis/config` for default values (student name, ID, language) when no CLI flags are provided.
- **REQ-012**: `chapter add` shall create a new chapter file, insert its `#include` in `main.typ` between marker regions, and auto-generate a header stub.
- **REQ-013**: `chapter add --after=N` / `--before=N` shall insert the chapter at the specified position and renumber subsequent chapters.
- **REQ-014**: `chapter remove N` shall delete the chapter file and its include line from `main.typ`.
- **REQ-015**: `chapter remove N --renumber` shall also shift subsequent chapter numbers down.
- **REQ-016**: `chapter move N --to=M` shall reorder chapters and rewrite all includes and filenames.
- **REQ-017**: `chapter list` shall display all chapters with their titles extracted from the `= Title` lines.
- **REQ-018**: `update --cli` shall reinstall the CLI from the latest git release, backing up `CTU_HOME` first.
- **REQ-019**: `update --templates` shall clear and re-download the template cache.
- **REQ-020**: `help [COMMAND]` shall display usage, flags, examples, and exit codes for the given command.

### Constraints

- **CON-001**: The CLI must be written entirely in Bash (>= 4.2). No Python, Node, or compiled language dependencies.
- **CON-002**: The raw `templates/` directory must compile standalone via `typst compile templates/main.typ` without the CLI present — the template is independently verifiable.
- **CON-003**: Template files must use `{{PLACEHOLDER}}` syntax for variable substitution, not Typst-native variables, to preserve standalone compilability.
- **CON-004**: The `init` command must never download templates at runtime. All template files must be co-located in the `templates/` directory shipped with the repo.
- **CON-005**: The CLI must not modify any files outside the project root (except `~/.ctu-thesis/` for config/cache and the symlink created by the installer).
- **CON-006**: All commands must provide meaningful exit codes (0=success, 1=error, 2=missing dependency, 4=validation failed, 5=user cancelled).
- **CON-007**: The install script (`install.sh`) must be a single `curl | bash` command that works on a fresh Linux/macOS system with only `curl` pre-installed.

### Format Guidelines (from Decision 4125/QĐ-ĐHCT 2024)

- **GUD-001**: Font: Times New Roman, 13pt (main text)
- **GUD-002**: Margins: left 4cm, right 2.5cm, top 2.5cm, bottom 2.5cm
- **GUD-003**: Line spacing: 1.2 (main text); single spacing (1.0) for captions, code, tables
- **GUD-004**: Paragraph: justified, first-line indent 1cm
- **GUD-005**: Page numbering: Roman numerals (`i, ii, iii...`) for front matter; Arabic (`1, 2, 3...`) from Part 1 onward
- **GUD-006**: Header: short thesis title (italic, 9pt) + horizontal line, main-content pages only
- **GUD-007**: Footer: horizontal line + centered page number, all numbered pages
- **GUD-008**: Abstract: 200-350 words, 3-5 keywords
- **GUD-009**: Bibliography: IEEE citation style, `backmatter/bibliography.bib`
- **GUD-010**: Cover: blue border (#003399), 2pt outer / 3pt inner
- **GUD-011**: Headings: Part (14pt bold uppercase centered), Chapter (14pt bold uppercase centered), Section (13pt bold uppercase left), Subsection (13pt bold sentence-case left)
- **GUD-012**: Figures: caption below, centered, single-spaced (0.15cm leading)
- **GUD-013**: Tables: caption above, centered, single-spaced (0.15cm leading)
- **GUD-014**: Code blocks: Courier New 10pt, #f5f5f5 background, 0.3cm padding, single-spaced

---

## 4. Architecture & Component Diagram

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     ctu-thesis CLI v2.0                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────┐     ┌──────────────────────────────────────┐     │
│  │ install.sh│     │  bin/ctu-thesis (entrypoint)         │     │
│  │ (one-liner│     │  ┌────────────────────────────────┐  │     │
│  │  curl|bash│     │  │ • Parse global flags (-v,-q,-h) │  │     │
│  │  install) │     │  │ • Source lib/core.sh           │  │     │
│  └──────────┘     │  │ • Dispatch to lib/commands/*.sh │  │     │
│                   │  └────────────────────────────────┘  │     │
│                   └──────────────────────────────────────┘     │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  lib/                                                    │   │
│  │  ├── core.sh          logging, config I/O, helpers       │   │
│  │  ├── version.sh       VERSION="1.0.0"                    │   │
│  │  └── commands/        per-command modules (sourced)       │   │
│  │      ├── init.sh      project scaffolding                 │   │
│  │      ├── build.sh     typst compile/watch/draft           │   │
│  │      ├── validate.sh  CTU guideline compliance checks     │   │
│  │      ├── doctor.sh    environment diagnostic              │   │
│  │      ├── clean.sh     artifact removal                    │   │
│  │      ├── config.sh    user defaults management            │   │
│  │      ├── chapter.sh   chapter CRUD operations             │   │
│  │      ├── update.sh    CLI + template update               │   │
│  │      └── help.sh      usage documentation                 │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  templates/  (co-located, standalone Typst project)      │   │
│  │  ├── main.typ         entrypoint with marker regions     │   │
│  │  ├── info.typ         {{PLACEHOLDER}} metadata           │   │
│  │  ├── compliance.json  format values mirror for validate  │   │
│  │  ├── template/        ctu-styles.typ, i18n.typ           │   │
│  │  ├── frontmatter/     cover, abstract, TOC, LOF, LOT...  │   │
│  │  ├── chapters/        part1/, part2/, part3/             │   │
│  │  ├── backmatter/      bibliography.bib, appendices.typ   │   │
│  │  └── images/logo/     CTU_logo.png                       │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Install-Time Architecture

```
User Machine
│
│  curl -fsSL <url>/install.sh | bash
│
├─► install.sh
│    ├─ 1. Check bash >= 4.2
│    ├─ 2. Create ~/.ctu-thesis/{bin,lib,commands,templates,cache}
│    ├─ 3. Download ctu-thesis (bundled script) → ~/.ctu-thesis/bin/
│    ├─ 4. Extract templates.tar.gz → ~/.ctu-thesis/templates/
│    ├─ 5. Create symlink: /usr/local/bin/ctu-thesis → ~/.ctu-thesis/bin/ctu-thesis
│    └─ 6. Run ctu-thesis doctor
│
└─► ~/.ctu-thesis/
     ├── bin/ctu-thesis          (bundled CLI, source module)
     ├── templates/              (complete Typst project)
     │   ├── main.typ
     │   ├── info.typ
     │   ├── compliance.json
     │   └── ...
     ├── config                  (user defaults)
     └── cache/                  (update snapshots)
```

### Toolchain Integration

```
┌──────────┐    ┌─────────────┐    ┌──────────────┐    ┌───────────┐
│ bash 4.2+ │◄───│ ctu-thesis   │───►│ typst 0.12+  │───►│ thesis.pdf │
│ (runtime) │    │ CLI          │    │ (compile)    │    │ (output)   │
└──────────┘    └─────────────┘    └──────────────┘    └───────────┘
                    │    │
                    │    └──► compliance.json ──► validate
                    │
                    └────► bats (tests) ──► CI
```

---

## 5. Use Cases

### UC-01: First-Time Student — Scaffold and Build

```
Actor: Undergraduate student, no prior Typst experience

Precondition: Typst installed, internet available for install

Flow:
1. Student runs:  curl .../install.sh | bash
2. Installer checks environment, downloads CLI + templates, creates symlink
3. Student runs:  ctu-thesis doctor
4. All checks pass (typst 0.12.0, TNR font found)
5. Student runs:  ctu-thesis config set student.name "Nguyen Van A"
                  ctu-thesis config set student.id "B2026001"
                  ctu-thesis config set lang vi
6. Student runs:  ctu-thesis init my-thesis --title "E-Commerce Platform" --advisor "TS. Tran Thi B"
7. CLI copies templates/ → my-thesis/, replaces {{PLACEHOLDER}}s
8. Student runs:  cd my-thesis && ctu-thesis build
9. CLI compiles → luan-van-vi.pdf
10. Student opens PDF — cover page shows Vietnamese, correct name, title

Postcondition: A complete, compilable thesis project with student metadata.
```

### UC-02: Advisor Review — Validate Before Submission

```
Actor: Thesis advisor or student

Precondition: Student has a populated thesis project

Flow:
1. Advisor runs:  ctu-thesis validate
2. CLI checks:
   ✓ Structure: all required files present
   ✓ Metadata: all keys in info.typ populated
   ✓ Format: font=TNR, margins=4cm/2.5cm, spacing=1.2
   ✓ Include resolution: all #include paths valid
   ✓ Bibliography: backmatter/bibliography.bib exists, non-empty
   ⚠ Abstract: 412 words (exceeds 350 max)
3. Student fixes abstract, re-runs validate
4. All checks pass: exit code 0

Postcondition: Project passes all CTU format checks.
```

### UC-03: Chapter Management During Writing

```
Actor: Student mid-thesis

Precondition: Existing project with 3 chapters

Flow:
1. Student:  ctu-thesis chapter add "System Architecture" --after=1
2. CLI creates chapters/chapter02.typ, inserts include in main.typ
3. Existing chapter 2 → chapter 3, chapter 3 → chapter 4
4. Student:  ctu-thesis chapter list
   Output:
   1. Background and Related Work
   2. System Architecture
   3. Design and Implementation
   4. Testing and Evaluation
5. Student:  ctu-thesis chapter remove 4
   CLI prompts: "Remove chapter 4 'Testing and Evaluation'? (y/N)"
6. Student confirms, chapter deleted

Postcondition: Three chapters, properly reordered and numbered.
```

### UC-04: CI Pipeline — Template Drift Detection

```
Actor: CI system (GitHub Actions)

Precondition: Developer pushes changes to info.typ

Flow:
1. Push triggers GitHub Actions CI
2. test_template_sync.bats job runs
3. Compares compliance.json ↔ info.typ values
4. Margin mismatch detected:
   FAIL: compliance.json: format.margins.left = "4cm"
         info.typ: settings.format.margins.left = "3.5cm"
5. CI fails, PR blocked
6. Developer updates compliance.json to match, re-pushes
7. CI passes

Postcondition: Template format values validated to be self-consistent.
```

### UC-05: Draft Mode for Quick Iteration

```
Actor: Student editing content, no references yet

Precondition: Project exists, bibliography empty or incomplete

Flow:
1. Student:  ctu-thesis build --draft
2. CLI temporarily comments out #bibliography(...) in main.typ
3. Compiles: typst compile main.typ luan-van-vi.pdf
4. Compilation succeeds (no missing citation errors)
5. On exit (success or Ctrl+C), CLI restores main.typ

Postcondition: PDF generated without bibliography, original main.typ intact.
```

### UC-06: Machine-Readable Doctor for IDE Plugin

```
Actor: IDE integration (future VSCode extension)

Precondition: ctu-thesis installed

Flow:
1. IDE plugin runs:  ctu-thesis doctor --json
2. Output:
   {"check":"bash","status":"ok","version":"5.1.16"}
   {"check":"typst","status":"ok","version":"0.12.0"}
   {"check":"git","status":"ok","version":"2.34.1"}
   {"check":"font_times_new_roman","status":"ok","path":"/usr/share/fonts/..."}
   {"check":"internet","status":"ok"}
   {"check":"project","status":"ok","root":"/home/user/my-thesis"}
   {"check":"template_cache","status":"ok"}
3. Plugin parses JSON, shows status bar indicators
4. Plugin marks TNR check green, typst check green

Postcondition: Structured diagnostic data available for integration.
```

---

## 6. Interfaces & Data Contracts

### 6.1 `compliance.json` Schema

```json
{
  "$schema": "https://ctu-thesis-cli/schemas/compliance-v1.json",
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
    "level1_weight": "bold",
    "level1_transform": "uppercase",
    "level1_align": "center",
    "level2_size": "13pt",
    "level2_weight": "bold",
    "level2_transform": "uppercase",
    "level3_size": "13pt",
    "level3_weight": "bold"
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

### 6.2 Template Placeholder Variables

| Placeholder | Type | Source | Example |
|---|---|---|---|
| `{{STUDENT_NAME}}` | string | `--student` / prompt / config | `Nguyen Van A` |
| `{{STUDENT_ID}}` | string | `--id` / prompt / config | `B2026001` |
| `{{STUDENT_CLASS}}` | string | `--class` / prompt / config | `DI2296A1` |
| `{{ADVISOR_NAME}}` | string | `--advisor` / prompt / config | `TS. Tran Thi B` |
| `{{ADVISOR_TITLE}}` | string | `--advisor-title` / prompt / config | `TS.` |
| `{{THESIS_TITLE}}` | string | `--title` / prompt / config | `E-Commerce Platform` |
| `{{SHORT_TITLE}}` | string | auto (first 50 chars of title) | `E-COMMERCE PLATFORM` |
| `{{LANG}}` | `"en"|"vi"` | `--lang` / prompt / config | `vi` |
| `{{THESIS_TYPE}}` | `"bachelor"` | `--type` / config | `bachelor` |
| `{{MAJOR}}` | string | `--major` / prompt / config | `INFORMATION TECHNOLOGY` |
| `{{PROGRAM}}` | string | `--program` / prompt / config | `High-Quality Program` |
| `{{YEAR}}` | integer | auto (`date +%Y`) | `2026` |
| `{{THESIS_DATE}}` | string | auto (`date +"%B %Y"`) | `May 2026` |
| `{{THESIS_LOCATION}}` | string | `--location` / config | `Can Tho` |
| `{{THESIS_DEGREE}}` | string | auto (from `--type`) | `BACHELOR OF ENGINEERING` |
| `{{THESIS_TYPE_VI}}` | string | auto (from `--type`) | `LUẬN VĂN TỐT NGHIỆP` |

### 6.3 `.ctu-thesisrc` Format

```ini
[project]
name=my-thesis
lang=vi
type=bachelor

[student]
name=Nguyen Van A
id=B2026001

[advisor]
name=TS. Tran Thi B
title=TS.

[chapter]
prefix=chapter
padding=2
auto_renumber=true
```

### 6.4 User Config (`~/.ctu-thesis/config`)

```ini
student.name=Nguyen Van A
student.id=B2026001
student.class=DI2296A1
advisor.name=TS. Tran Thi B
advisor.title=TS.
lang=vi
type=bachelor
```

### 6.5 Marker Regions (in `main.typ`)

```
// -- CTU-THESIS-CHAPTERS-START --
// Do not edit between these markers; managed by ctu-thesis CLI.
#include "chapters/chapter01.typ"
#include "chapters/chapter02.typ"
// -- CTU-THESIS-CHAPTERS-END --
```

### 6.6 Exit Codes

| Code | Meaning |
|---|---|
| 0 | Success |
| 1 | General error |
| 2 | Missing dependency (typst not installed, font not found) |
| 3 | Network error (update failed, internet unreachable) |
| 4 | Validation failed (project does not pass CTU checks) |
| 5 | User cancelled (prompt declined, aborted) |

---

## 7. Acceptance Criteria

### AC-001: Full Scaffold → Compile → PDF
**Given** a clean system with bash 4.2+, `curl`, and typst 0.12+ installed
**When** user runs `curl .../install.sh | bash && ctu-thesis init test-thesis && cd test-thesis && ctu-thesis build`
**Then** a valid PDF is generated at `test-thesis/thesis-en.pdf` (or `luan-van-vi.pdf` for `--lang=vi`) with no compilation errors.

### AC-002: Standalone Template Compiles
**Given** the `templates/` directory is copied directly from the repo
**When** `typst compile templates/main.typ templates/test.pdf` is run
**Then** compilation succeeds and produces a PDF with visible `{{PLACEHOLDER}}` text (e.g., "YOUR NAME HERE").

### AC-003: Validation Catches Format Drift
**Given** a project where `info.typ` has `left: 3cm` instead of `4cm`
**When** `ctu-thesis validate` is run
**Then** the check fails with exit code 4 and displays: "FAIL: margin.left=3cm, expected=4cm".

### AC-004: Draft Mode Preserves Original
**Given** a project with bibliography references
**When** user presses Ctrl+C during `ctu-thesis build --draft`
**Then** `main.typ` is restored to its original state (bibliography line intact).

### AC-005: Chapter Add Renumbers Correctly
**Given** a project with 3 chapters (01, 02, 03)
**When** `ctu-thesis chapter add "New Chapter" --before=2` is run
**Then** new chapter becomes `chapter02.typ`, old 02 → `chapter03.typ`, old 03 → `chapter04.typ`.

### AC-006: Chapter Remove With Renumber
**Given** a project with 4 chapters
**When** `ctu-thesis chapter remove 2 --renumber --force` is run
**Then** chapter02 is deleted, chapter03 → chapter02, chapter04 → chapter03, all includes updated.

### AC-007: Doctor JSON Output Is Valid
**Given** a valid environment
**When** `ctu-thesis doctor --json` is run
**Then** output is a sequence of valid JSON objects (one per line), parseable by `jq`.

### AC-008: Config Round-Trip
**Given** no existing config file
**When** `ctu-thesis config set test.key "hello world"` then `ctu-thesis config get test.key`
**Then** output is `"hello world"`, and the config file persists the value.

### AC-009: Init Respects Config Defaults
**Given** `ctu-thesis config set student.name "Jane Doe"` has been run
**When** `ctu-thesis init proj --lang=vi` (no `--student` flag)
**Then** generated `info.typ` contains `name: "Jane Doe"`.

### AC-010: Init Interactive Prompts When Missing
**Given** `ctu-thesis config` has no value for `student.name`
**When** `ctu-thesis init proj` runs (no `--student` flag, not `--non-interactive`)
**Then** user is prompted: "Your full name: " before generation proceeds.

### AC-011: Template Sync CI Blocks Drift
**Given** a PR changes `info.typ` margins from `4cm` to `3.5cm` without updating `compliance.json`
**When** CI runs `test_template_sync.bats`
**Then** CI fails with a clear message identifying the specific field mismatch.

### AC-012: Init Refuses Overwrite Without --force
**Given** directory `my-thesis/` already exists
**When** `ctu-thesis init my-thesis` is run
**Then** CLI refuses with: "my-thesis/ already exists. Use --force to overwrite." Exit code 1.

---

## 8. Test Automation Strategy

### Test Levels
- **Unit (bats)**: Each command's core logic tested in isolation with mocked dependencies where possible
- **Integration (bats)**: Full `init → build → validate` pipeline tested end-to-end in temp directories
- **CI Gate**: `test_template_sync.bats` prevents format drift between `info.typ` and `compliance.json`

### Frameworks
- **bats-core** for all test suites
- **shellcheck** for static analysis / linting
- **GitHub Actions** for CI pipeline execution

### Test Data Management
- Every test creates a fresh temp directory via `test_helper.bash` `setup()`
- `CTU_HOME` is overridden to the temp directory — no pollution of user's real config
- Cleanup via `teardown()` removes all temp artifacts
- Template fixture: the real `templates/` directory is used as-is (no mocking of Typst files)

### CI/CD Integration
- Runs on push/PR to `main`
- `shellcheck` step: lint all `.sh` files
- `template-sync` step: verify `compliance.json` ↔ `info.typ` consistency
- `template-compile` step: `typst compile templates/main.typ` (verifies raw template renders)
- `bats` step: full test suite

### Coverage Requirements
- Every public command must have at least: happy-path test, error-path test, one boundary/edge-case test
- Every exit code branch must be exercised
- Template sync test must run on every PR

---

## 9. Rationale & Context

### Why Bash (not Python/Node)?
- CTU students use diverse systems (Windows with Git Bash, Linux, macOS). Bash 4.2+ is the lowest common denominator that works on all without additional runtimes.
- The primary dependency chain is install → typst compile. Adding Python or Node as a pre-requisite doubles the setup burden.
- The earlier `_resys.ctu.template/` experiment proved Bash is sufficient for the full feature set.

### Why Co-located Templates (not runtime download)?
- The old CLI's biggest failure was downloading templates at runtime: only top-level files fetched, subdirectories empty, generated project couldn't compile.
- Embedding as bash strings (~80KB in `generate-ctu-thesis.sh`) caused escaping nightmares and maintenance hell.
- Co-located `.typ` files are: independently compilable, diffable in git, syntax-highlighted in editors, and directly testable.

### Why `{{PLACEHOLDER}}` (not Typst variables)?
- If the template used Typst variables (`#let student_name = "..."`), the raw template couldn't compile standalone — it would need a `#let` definition that doesn't exist yet.
- `{{PLACEHOLDER}}` text renders as literal text in Typst ("YOUR NAME HERE"), so the template compiles without the CLI and produces a valid (if placeholder-filled) PDF.
- `sed` substitution is simple, fast, and has no escaping issues with Typst syntax.

### Why `compliance.json` (not bash config)?
- JSON is parseable by any language — future IDE plugins or web frontends can read it without bash.
- Separates the "what should the format be" from "how do we render it" — `info.typ` handles the latter.
- CI can trivially compare two structured data sources (vs. parsing Typst syntax in bash, which is brittle).

### Why Rebuild (not Refactor) `_resys.ctu.template/`?
- The old CLI hardcoded template URLs, downloaded from GitHub, had empty generated subdirectories, and mixed concerns across files.
- The command-dispatch architecture (`bin/` → `lib/` → `lib/commands/`) is sound and worth keeping.
- Starting fresh with a clean repo lets us adopt the co-located template model, proper test coverage from day one, and a simpler install flow — with less cleanup overhead than refactoring around broken abstractions.

---

## 10. Dependencies & External Integrations

### External Systems
- **EXT-001**: CTU website/admin portal — source of formatting guideline updates (Decision 4125/QĐ-ĐHCT). Not programmatically integrated; manual review of guideline changes required.

### Third-Party Services
- **SVC-001**: GitHub Releases — distribution channel for bundled CLI and template tarball. Used by `install.sh` and `update` command.
- **SVC-002**: GitHub raw file hosting — serves `install.sh` for the one-liner install URL.

### Infrastructure Dependencies
- **INF-001**: Typst compiler v0.12.0+ — required for `build`, optional for other commands. Available at https://github.com/typst/typst/releases.
- **INF-002**: Times New Roman font — required by CTU guidelines. Available via `ttf-mscorefonts-installer` (Linux), pre-installed (macOS), or bundled with MS Office (Windows).

### Data Dependencies
- **DAT-001**: `templates/` directory — the canonical source for all Typst template files. Must be co-located with CLI source at install time.
- **DAT-002**: `compliance.json` — the canonical source for format validation values. Must be kept in sync with `templates/info.typ`.

### Technology Platform Dependencies
- **PLT-001**: Bash >= 4.2 — required for associative arrays, `readarray`, and other modern bash features used by the CLI.
- **PLT-002**: `sed` (POSIX) — used for placeholder substitution and marker region management.
- **PLT-003**: `curl` — required for install and update operations.
- **PLT-004**: `git` — optional; recommended for version control of thesis projects. Required only if using `update --cli`.

### Compliance Dependencies
- **COM-001**: Decision 4125/QĐ-ĐHCT (2024) — the official CTU regulation defining thesis formatting requirements. Values from this decision are encoded in `templates/info.typ` and `templates/compliance.json`.

---

## 11. Examples & Edge Cases

### Example: Full Vietnamese Bachelor Thesis Scaffold

```bash
$ ctu-thesis config set student.name "Nguyễn Văn A"
$ ctu-thesis config set student.id "B2026001"
$ ctu-thesis config set student.class "DI2296A1"
$ ctu-thesis config set advisor.name "TS. Trần Thị B"
$ ctu-thesis config set advisor.title "TS."
$ ctu-thesis config set lang vi

$ ctu-thesis init luan-van \
    --title "Hệ Thống Thương Mại Điện Tử" \
    --major "CÔNG NGHỆ THÔNG TIN" \
    --program "Chất lượng cao"

Creating project: luan-van/
  ✓ Copying templates...
  ✓ Setting Vietnamese language...
  ✓ Replacing placeholders...
  ✓ Creating .ctu-thesisrc

Done! Next steps:
  cd luan-van
  ctu-thesis build        # Compile to luan-van-vi.pdf
  ctu-thesis build --watch # Auto-recompile on save
  ctu-thesis chapter add "Tổng Quan"  # Add a chapter

$ cd luan-van && ctu-thesis build
  ✓ Typst 0.12.0 found
  ✓ Times New Roman font found
  ⚡ Compiling...
  ✓ luan-van-vi.pdf generated (45 pages)
```

### Edge Case: Non-English, Non-Vietnamese Language

```
$ ctu-thesis init thesis --lang=fr
Error: Unsupported language 'fr'. Valid options: en, vi.
Exit code: 1
```

### Edge Case: Init Without Any Metadata

```
$ ctu-thesis init thesis --non-interactive
Creating project: thesis/
  ✓ Copying templates...
  ⚠ No student name provided. Defaulting to "YOUR NAME HERE"
  ⚠ No student ID provided. Defaulting to "B0000000"
  ⚠ No title provided. Defaulting to "YOUR THESIS TITLE"
  ✓ Creating .ctu-thesisrc

Done! Edit info.typ to set your actual information.
```

### Edge Case: Draft Mode with Ctrl+C

```
$ ctu-thesis build --draft
  ⚡ Compiling draft (bibliography skipped)...
  ^C
  ⚠ Build interrupted.
  ✓ Restored main.typ (draft mode cleaned up)
Exit code: 130
```

### Edge Case: Validate on Empty Project

```
$ ctu-thesis init empty-project --non-interactive
$ cd empty-project
$ ctu-thesis validate
  ✗ Metadata: student.name is placeholder "YOUR NAME HERE"
  ✗ Metadata: thesis.title is placeholder "YOUR THESIS TITLE"
  ✗ Metadata: only 2 keywords provided (need 3-5)
  ✗ Bibliography: backmatter/bibliography.bib is empty
  ✗ Abstract: no content found
4 validation failures, 2 warnings found.
Exit code: 4
```

### Edge Case: Chapter Remove Only Chapter

```
$ ctu-thesis chapter list
1. Introduction

$ ctu-thesis chapter remove 1
Error: Cannot remove the only remaining chapter.
A thesis must have at least 1 chapter.
Exit code: 1
```

### Edge Case: UTF-8 in Project Path

```
$ ctu-thesis init "luận-văn-của-tôi"  # works fine
$ ctu-thesis init "my thesis"          # discouraged but works
$ ctu-thesis init "my:thesis"          # Error: invalid characters in path
```

---

## 12. Validation Criteria

| ID | Criteria | Verification Method |
|---|---|---|
| VC-01 | `templates/` compiles standalone to PDF | `typst compile templates/main.typ` → exit 0, PDF exists |
| VC-02 | Generated project compiles to PDF | `init → build` → exit 0, PDF exists |
| VC-03 | `validate` catches all format mismatch types | Bats test with contrived violations |
| VC-04 | `doctor` reports all environment aspects | Manual run on clean VM |
| VC-05 | `doctor --json` output is valid JSON | `ctu-thesis doctor --json \| jq .` succeeds for each line |
| VC-06 | `chapter` commands preserve non-marker content in `main.typ` | Bats test: add chapter, verify other includes untouched |
| VC-07 | `build --draft` restores `main.typ` on SIGINT | Bats test: send signal, verify file content unchanged |
| VC-08 | `config` survives special characters in values | Bats test: `set key "hello = world"` then `get key` returns same |
| VC-09 | `compliance.json` ↔ `info.typ` in sync | CI gate, bats test |
| VC-10 | `install.sh` works on fresh Ubuntu 22.04 | Docker-based CI test |
| VC-11 | All commands return correct exit codes | Bats test for each exit code path |
| VC-12 | `init --force` overwrites existing directory | Bats test |

---

## 13. Related Specifications / Further Reading

- [CTU Thesis Guidelines 2025-2026 (English)](../../docs/CTU_THESIS_GUIDELINES.md)
- [CTU Thesis Guidelines (Vietnamese)](../../docs/CTU_THESIS_GUIDELINES_VI.md)
- [Old CLI Design Spec](../../_resys.ctu.template/docs/superpowers/specs/2026-05-25-ctu-thesis-cli-design.md) — the `_resys.ctu.template/` experiment (for reference)
- [Old CLI Implementation Plan](../../_resys.ctu.template/docs/superpowers/plans/2026-05-25-ctu-thesis-cli-implementation.md) — implementation plan for the old CLI (for reference)
- [Decision 4125/QĐ-ĐHCT (2024)](https://www.ctu.edu.vn/) — official CTU regulation (verify with your department for latest version)
- [Typst Documentation](https://typst.app/docs)
- [IEEE Citation Guidelines](https://ieeeauthorcenter.ieee.org/wp-content/uploads/IEEE-Reference-Guide.pdf)
- [bats-core Documentation](https://bats-core.readthedocs.io/)

---

## Appendix A: Command Reference Quick-Card

| Command | Flags | Description |
|---|---|---|
| `init [PATH]` | `--type`, `--lang`, `--title`, `--student`, `--id`, `--advisor`, `--advisor-title`, `--class`, `--major`, `--program`, `--location`, `--non-interactive`, `--force` | Scaffold complete thesis project |
| `build` | `--watch`, `--draft`, `--output` | Compile thesis to PDF |
| `validate` | `--fix`, `--json` | Check CTU guideline compliance |
| `doctor` | `--json` | Diagnostic environment check |
| `clean` | `--all` | Remove build artifacts |
| `config` | `set KEY VAL`, `get KEY`, `list`, `unset KEY` | Manage user defaults |
| `chapter` | `add TITLE [--after=N\|--before=N]`, `remove N [--force] [--renumber]`, `list`, `move N --to=M` | Chapter CRUD operations |
| `update` | `--cli`, `--templates` | Update CLI and/or template cache |
| `help` | `[COMMAND]` | Show usage help |

