# CTU Thesis CLI

> A cross-platform Bash CLI for Can Tho University (CTU) students to scaffold, build, validate, and manage Typst thesis projects — compliant with Decision 4125/QĐ-ĐHCT (2024).

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/ngtphat-towa/CTU-Thesis-Template/main/install.sh | bash
```

## Quick Start

```bash
# Create a new project
ctu-thesis init my-thesis --lang=en --title="My Research Topic"

# Build and watch
cd my-thesis
ctu-thesis build
ctu-thesis build --watch
```

## Features

| Command | What it does |
|---|---|
| `ctu-thesis init PATH` | Scaffold a complete, compilable thesis project |
| `ctu-thesis build` | Compile to PDF (supports --watch and --draft) |
| `ctu-thesis validate` | Check CTU guideline compliance (structure, format, bibliography) |
| `ctu-thesis doctor` | Diagnose your environment (bash, typst, fonts, internet) |
| `ctu-thesis clean` | Remove build artifacts (*.pdf, *.tmp, *.bak) |
| `ctu-thesis config` | Manage user defaults (name, ID, language, advisor) |
| `ctu-thesis chapter` | Add, remove, list, or reorder chapters |
| `ctu-thesis update` | Refresh CLI and/or template cache |
| `ctu-thesis help` | Show command reference and usage |

## Requirements

- **Bash** >= 4.2
- **Typst** >= 0.12.0 (for `build`)
- **curl** (for install/update)
- **Times New Roman** font (recommended; Typst uses fallback if missing)

## CTU Format Compliance

This template enforces the following values per Decision 4125/QĐ-ĐHCT (2024):

| Requirement | Value |
|---|---|
| Font | Times New Roman 13 pt |
| Margins | Left 4 cm, Others 2.5 cm |
| Line Spacing | 1.2 (main text); single for captions/code |
| Paragraph | Justified, first-line indent 1 cm |
| Abstract | 200–350 words, 3–5 keywords |
| Bibliography | IEEE style |
| Cover Color | CTU Blue (#003399) |

## Project Structure

```
my-thesis/
├── info.typ                  # ⚙️ Edit this first (your info)
├── main.typ                  # 📄 Entry point with marker regions
├── .ctu-thesisrc             # 📋 CLI project config
├── template/                 # 🎨 Style definitions (edit with care)
├── frontmatter/              # 📝 Cover, abstract, TOC, abbreviations
├── chapters/                 # 📚 Your thesis content
├── backmatter/               # 📎 References & appendices
└── images/                   # 🖼️ Image assets
```

## Development

```bash
git clone https://github.com/ngtphat-towa/ctu-thesis-cli
cd ctu-thesis-cli

make lint       # shellcheck
make test       # bats tests
make bundle     # create distribution artifacts in dist/
```

## License

MIT
