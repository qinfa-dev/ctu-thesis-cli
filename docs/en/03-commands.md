# 03 - Commands

## Command overview

| Command | Description |
|---------|-------------|
| `init` | Scaffold a new thesis project |
| `build` | Compile thesis to PDF |
| `validate` | Check CTU guideline compliance |
| `doctor` | Diagnose environment issues |
| `clean` | Remove build artifacts |
| `config` | Manage user and project settings |
| `chapter` | Add, remove, list, reorder chapters |
| `update` | Refresh CLI binary and/or templates |
| `help` | Show command reference |

---

## `ctu-thesis init`

Scaffolds a complete thesis project from the template cache.

```bash
ctu-thesis init <project-path> [options]
```

### Options

| Flag | Description | Default |
|------|-------------|---------|
| `--lang=en` | Primary language | `en` |
| `--lang=vi` | Vietnamese mode | — |
| `--title="..."` | Thesis title | `Your Thesis Title` |
| `--name="..."` | Student name | `{{STUDENT_NAME}}` (placeholder) |
| `--id="..."` | Student ID | `{{STUDENT_ID}}` (placeholder) |
| `--class="..."` | Student class | `{{STUDENT_CLASS}}` (placeholder) |
| `--advisor="..."` | Advisor name | `{{ADVISOR_NAME}}` (placeholder) |
| `--force` | Overwrite existing directory | off |

### Examples

```bash
# English thesis
ctu-thesis init my-thesis --lang=en --title="E-commerce Recommendation System"

# Vietnamese thesis
ctu-thesis init luan-van --lang=vi --title="Hệ thống gợi ý thương mại điện tử"

# With full info
ctu-thesis init my-thesis \
  --lang=en \
  --title="Machine Learning in Healthcare" \
  --name="Nguyen Van A" \
  --id="B2000001" \
  --class="DI20V8A1" \
  --advisor="Dr. Tran Van B"

# Force overwrite
ctu-thesis init my-thesis --force
```

---

## `ctu-thesis build`

Compiles the Typst thesis project to PDF.

```bash
ctu-thesis build [options]
```

Must be run from inside a thesis project directory.

### Options

| Flag | Description |
|------|-------------|
| `--watch` | Watch for changes and auto-recompile |
| `--draft` | Fast compilation (skip some formatting for speed) |
| `--output=<path>` | Custom PDF output path (default: `<project-dir>.pdf`) |

### Examples

```bash
# One-time build
ctu-thesis build

# Watch mode
ctu-thesis build --watch

# Draft mode (faster, skip validation)
ctu-thesis build --draft

# Custom output path
ctu-thesis build --output=build/thesis-v2.pdf
```

---

## `ctu-thesis validate`

Checks project compliance against CTU formatting rules.

```bash
ctu-thesis validate [options]
```

### Checks performed

- Required files and directories exist
- Abstract word count (200–350)
- Keywords count (3–5)
- Reference count (minimum 15)
- `compliance.json` matches `info.typ`
- Missing/invalid chapters
- Image references

### Options

| Flag | Description |
|------|-------------|
| `--strict` | All warnings become errors (exit code changes) |
| `--fix` | Auto-fix minor issues when possible |

### Examples

```bash
# Basic validation
ctu-thesis validate

# Strict mode for CI/CD
ctu-thesis validate --strict

# Auto-fix issues
ctu-thesis validate --fix
```

### Exit codes

| Code | Meaning |
|------|---------|
| 0 | All checks passed |
| 4 | Validation failed (warnings or errors) |

---

## `ctu-thesis doctor`

Diagnoses your environment for issues.

```bash
ctu-thesis doctor
```

### Checks performed

- Bash version >= 4.2
- Typst CLI installed and version
- curl available
- Times New Roman font available
- Internet connectivity
- Template cache exists and is valid
- `~/.ctu-thesis/config` readable

### Example output

```
✓ bash 5.2.15 (>= 4.2)
✓ typst 0.12.0 (>= 0.12.0)
✓ curl 8.5.0
✓ Times New Roman installed
✓ Internet: connected
✓ Template cache: valid
✓ Config: /home/user/.ctu-thesis/config

All checks passed.
```

---

## `ctu-thesis clean`

Removes build artifacts from the project directory.

```bash
ctu-thesis clean [options]
```

### Removes

- `*.pdf` (compiled thesis files)
- `*.tmp` (temporary files)
- `*.bak` (backup files)

### Options

| Flag | Description |
|------|-------------|
| `--all` | Also remove Typst cache directory |
| `--dry-run` | Show what would be deleted without removing |

### Examples

```bash
# Basic cleanup
ctu-thesis clean

# Deep clean
ctu-thesis clean --all

# Preview
ctu-thesis clean --dry-run
```

---

## `ctu-thesis config`

Manage user defaults and project settings.

```bash
ctu-thesis config [subcommand] [options]
```

### Subcommands

| Subcommand | Description |
|-----------|-------------|
| `set <key> <value>` | Set a config value |
| `get <key>` | Get a config value |
| `list` | Show all config values |
| `unset <key>` | Remove a config value |
| `init` | Create `.ctu-thesisrc` from global config |

### Config keys

| Key | Description | Example |
|-----|-------------|---------|
| `student.name` | Full name | `Nguyen Van A` |
| `student.id` | Student ID | `B2000001` |
| `student.class` | Class name | `DI20V8A1` |
| `student.major` | Major | `Software Engineering` |
| `student.program` | Program type | `High-Quality Program` |
| `advisor.name` | Advisor name | `Dr. Tran Van B` |
| `advisor.title` | Advisor title | `Dr.` |
| `defaults.lang` | Default language | `en` or `vi` |

### Examples

```bash
# Set global defaults (used by `init` when flags not provided)
ctu-thesis config set student.name "Nguyen Van A"
ctu-thesis config set student.id "B2000001"
ctu-thesis config set defaults.lang "vi"

# View all config
ctu-thesis config list

# Initialize project config from globals
cd my-thesis
ctu-thesis config init

# Get a specific value
ctu-thesis config get student.name
```

### Config file locations

| File | Scope |
|------|-------|
| `~/.ctu-thesis/config` | Global user defaults (ini format) |
| `<project>/.ctu-thesisrc` | Project-specific overrides |

---

## `ctu-thesis chapter`

Manage thesis chapters within marker regions in `main.typ`.

```bash
ctu-thesis chapter <subcommand> [args]
```

### Subcommands

| Subcommand | Description |
|-----------|-------------|
| `list` | List all chapters in order |
| `add <name>` | Add a new chapter at the end |
| `remove <name>` | Remove a chapter |
| `reorder` | Interactively reorder chapters |

### How chapters work

`main.typ` contains marker regions:

```typst
// -- CTU-THESIS-CHAPTERS-START --
#include "chapters/part1-introduction.typ"
#include "chapters/part2-content.typ"
#include "chapters/part3-conclusion.typ"
// -- CTU-THESIS-CHAPTERS-END --
```

The CLI only reads/writes between these markers.

### Examples

```bash
# List all chapters
ctu-thesis chapter list

# Add a new chapter
ctu-thesis chapter add "chapter4-results.typ"

# Remove a chapter
ctu-thesis chapter remove "appendix-old.typ"

# Interactive reorder (opens an editor-like interface)
ctu-thesis chapter reorder
```

---

## `ctu-thesis update`

Update the CLI binary and/or the template cache.

```bash
ctu-thesis update [options]
```

### Options

| Flag | Description |
|------|-------------|
| `--cli` | Update CLI binary only |
| `--templates` | Update template cache only |
| `--check` | Check for updates without installing |

### Examples

```bash
# Update everything
ctu-thesis update

# Update only CLI
ctu-thesis update --cli

# Update only templates
ctu-thesis update --templates

# Check for updates
ctu-thesis update --check
```

---

## `ctu-thesis help`

Show help for any command.

```bash
ctu-thesis help [command]
```

### Examples

```bash
# General help
ctu-thesis help

# Command-specific help
ctu-thesis help build
ctu-thesis help config
```
