# Changelog

All notable changes to CTU Thesis CLI are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-05-25

### Added

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
- 29 Typst files with full CTU format compliance (Decision 4125/QĐ-ĐHCT 2024)
- `compliance.json` ↔ `info.typ` drift detection via CI gate
- Bilingual support (English/Vietnamese) with auto-generated VI translations
- Times New Roman 13pt, 4cm/2.5cm margins, IEEE bibliography, CTU Blue (#003399) cover
- Standalone compilable: `typst compile templates/main.typ` works without the CLI

**Infrastructure:**
- 33 bats tests across 8 test suites
- CI pipeline: shellcheck lint, template sync validation, template compile, bats tests
- `install.sh` one-liner installer (curl | bash)
- `make bundle` distribution target (40 KB CLI + 270 KB templates)
- Cross-platform: Linux, macOS, Windows (Git Bash, WSL, Cygwin)
- 10 community files (CONTRIBUTING, CODE_OF_CONDUCT, SECURITY, CITATION, CHANGELOG, AGENTS, codemeta.json, package.json, issue templates)

### Fixed
- Windows font detection in `doctor` command (Git Bash `/c/Windows/Fonts/`, WSL `/mnt/c/Windows/Fonts/`, `$SystemRoot`)
- macOS font detection in `doctor` command (`/System/Library/Fonts/`, `/Library/Fonts/`)
- Platform-specific font install hints in `doctor` warning message
- Repository URLs updated to canonical `qinfa-dev/ctu-thesis-cli` across all files
- Shellcheck lint warnings in `lib/version.sh` (shebang, SC2148, SC2034)

[1.0.0]: https://github.com/qinfa-dev/ctu-thesis-cli/releases/tag/v1.0.0
