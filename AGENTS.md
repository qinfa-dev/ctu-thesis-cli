# CTU Thesis CLI — Agent Notes

## What this repo is

A Bash CLI tool (`ctu-thesis`) that scaffolds, builds, validates, and manages Typst thesis projects for Can Tho University students. Written in Bash 4.2+, tested with bats-core.

## Key architecture facts

- **Command dispatch**: Thin `bin/ctu-thesis` entrypoint → sources `lib/core.sh` (shared utilities) → sources `lib/commands/<command>.sh` (auto-executes).
- **Template model**: `templates/` is a complete, independently compilable Typst project. `ctu-thesis init` copies it and runs `sed` to replace `{{PLACEHOLDER}}` markers.
- **Format compliance**: `templates/compliance.json` mirrors the format values in `templates/info.typ`. CI runs `tests/test_template_sync.sh` to prevent drift. Both must change together.
- **Chapter management**: Uses `// -- CTU-THESIS-CHAPTERS-START --` / `// -- CTU-THESIS-CHAPTERS-END --` marker regions in `templates/main.typ`. The CLI only reads/writes between these markers.
- **No runtime downloads**: All template files are co-located in `templates/`. The `install.sh` one-liner downloads everything at install time, then `init` copies from `~/.ctu-thesis/templates/`.

## Build, test, lint

```bash
# Tests (requires bats-core)
make test          # Full suite: 33 tests across 8 test files
bats tests/        # Or run directly
bats tests/test_init.bats  # Run a single test file

# Lint (requires shellcheck)
make lint
shellcheck bin/ctu-thesis lib/core.sh lib/commands/*.sh install.sh

# Bundle for distribution
make bundle        # Creates dist/ctu-thesis + dist/templates.tar.gz

# Install locally
make install       # Copies to ~/.local/
```

## Code conventions

- Bash >= 4.2 required (uses `declare -A` associative arrays, `mapfile`, etc.)
- `set -euo pipefail` at top of every script
- Commands: `ctu_<command>()` — called from `bin/ctu-thesis` dispatch
- Private helpers: `_ctu_<name>()` — underscore prefix
- Help functions: `ctu_help_<command>()` — used by `help` command
- Logging: `ctu_log_info`, `ctu_log_ok`, `ctu_log_warn`, `ctu_log_error`, `ctu_log_debug`
- Config: `~/.ctu-thesis/config` (ini-style key=value)
- Exit codes: 0=success, 1=error, 2=missing dep, 4=validation failed, 5=cancelled
- Template files are plain Typst — treat them as content, not code

## Important gotchas

- **`set -euo pipefail` + `((count++))`**: When `count=0`, `((count++))` returns 1 (falsy), triggering `set -e`. Use `count=$((count + 1))` instead.
- **macOS vs Linux sed**: macOS requires `sed -i ''`, Linux uses `sed -i`. Check `uname` before inline sed edits.
- **Command auto-execute**: Command files are `source`d, not exec'd. They execute `ctu_<command> "${COMMAND_ARGS[@]}"` at the bottom. When `help` sources them to load `ctu_help_<command>`, guard with `if [[ "${COMMAND:-}" == "<name>" ]]`.
- **`COMMAND_ARGS`** is set by the entrypoint before sourcing the command file. Don't use positional params — use `COMMAND_ARGS`.
- **CTU_HOME paths**: Everything installs to `~/.ctu-thesis/`. Tests override `CTU_HOME` via `test_helper.bash` to a temp directory.
