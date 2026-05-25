# Changelog

## [1.0.0] - 2026-05-25

### Initial Release

**9 Commands:**
- `init` — Scaffold complete, compilable thesis projects with `{{PLACEHOLDER}}` substitution
- `build` — Compile to PDF with `--watch` and `--draft` modes
- `validate` — Check CTU guideline compliance (structure, format, bibliography, includes)
- `doctor` — Diagnostic environment check with `--json` machine-readable output
- `config` — Manage user defaults (set, get, list, unset)
- `chapter` — Chapter CRUD with marker region management and auto-renumbering
- `clean` — Remove build artifacts
- `update` — Refresh CLI and/or template cache
- `help` — Command reference and usage documentation

**Template Features:**
- 29 Typst files with full CTU format compliance
- `compliance.json` ↔ `info.typ` drift detection
- Bilingual support (English/Vietnamese)
- Times New Roman 13pt, IEEE bibliography, CTU Blue cover
- Standalone compilable: `typst compile templates/main.typ` works without the CLI

**Infrastructure:**
- 33 bats tests across 8 test suites
- CI pipeline (shellcheck + template sync + template compile + bats)
- `install.sh` one-liner installer
- `make bundle` distribution target
- Built on bash 4.2+, tested on Linux
