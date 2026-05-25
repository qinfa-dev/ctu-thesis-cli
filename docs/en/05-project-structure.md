# 05 - Project Structure

## Directory tree

```
my-thesis/
├── info.typ                       # ⚙️  Thesis metadata — EDIT FIRST
├── main.typ                       # 📄  Entry point document
├── .ctu-thesisrc                  # 📋  Project configuration
│
├── template/                      # 🎨  Style definitions (do not edit)
│   ├── ctu-styles.typ            # CTU formatting rules
│   └── i18n.typ                  # Bilingual label mappings
│
├── frontmatter/                   # 📝  Front matter pages
│   ├── cover.typ                 # Outer cover page
│   ├── inner-cover.typ           # Inner cover page
│   ├── evaluation.typ            # Advisor evaluation page
│   ├── acknowledgements.typ      # Acknowledgements
│   ├── abstract.typ              # Abstract (200–350 words)
│   ├── table-of-contents.typ     # Auto-generated TOC
│   ├── list-of-figures.typ       # Auto-generated LOF
│   ├── list-of-tables.typ        # Auto-generated LOT
│   └── abbreviations.typ         # Abbreviations list
│
├── chapters/                      # 📚  Your thesis content
│   ├── part1-introduction.typ    # Part 1: Introduction container
│   ├── part2-content.typ         # Part 2: Main content container
│   ├── part3-conclusion.typ      # Part 3: Conclusion container
│   ├── part1/                    # Part 1 sections
│   │   ├── 01-context.typ
│   │   ├── 02-related-work.typ
│   │   ├── 03-objectives.typ
│   │   ├── 04-research-content.typ
│   │   └── 05-outline.typ
│   ├── part2/                    # Part 2 chapters
│   │   ├── chapter1-background.typ
│   │   ├── chapter2-design.typ
│   │   └── chapter3-evaluation.typ
│   └── part3/                    # Part 3 sections
│       ├── 01-conclusion.typ
│       └── 02-future-work.typ
│
├── backmatter/                    # 📎  Back matter
│   ├── bibliography.bib          # IEEE references (BibTeX)
│   └── appendices.typ            # Appendices
│
└── images/                        # 🖼️  Image assets
    ├── logo/                     # CTU logos
    └── chapter1/                 # Per-chapter figure folders
```

## Key files explained

### `info.typ`

Single source of truth for all thesis metadata. Student info, advisor, thesis title, keywords, abbreviations, language setting, and format parameters. See [Configuration](04-configuration.md) for full details.

### `main.typ`

Entry point that assembles the entire document:

1. Imports `info.typ` and template styles
2. Sets up document metadata
3. Renders front matter (covers, TOC, LOF, LOT, abstract, abbreviations)
4. Renders chapters via marker region
5. Renders back matter (bibliography, appendices)

### Chapter marker region

`main.typ` contains a special marker region for chapter includes:

```typst
// -- CTU-THESIS-CHAPTERS-START --
#include "chapters/part1-introduction.typ"
#include "chapters/part2-content.typ"
#include "chapters/part3-conclusion.typ"
// -- CTU-THESIS-CHAPTERS-END --
```

The CLI reads and writes only between these markers when managing chapters. Do not edit the marker lines themselves.

### `template/`

Contains CTU-compliant style definitions. These implement the formatting rules from Decision 4125/QĐ-ĐHCT (2024):

- `ctu-styles.typ` — page setup, margins, fonts, heading styles, headers/footers, cover layout
- `i18n.typ` — bilingual label mappings (e.g., "Abstract" ↔ "Tóm tắt")

These files should only be edited if you need to customize formatting beyond what CTU requires.

### `frontmatter/`

Each `.typ` file renders one front matter page. The `abstract.typ` and `acknowledgements.typ` files contain placeholder text you should replace.

### `chapters/`

Your actual thesis content. Organized by parts:

- **Part 1 (Introduction)**: Context, related work, objectives, research content, outline
- **Part 2 (Content)**: Main chapters — background, design/implementation, testing/evaluation
- **Part 3 (Conclusion)**: Conclusion and future work

### `backmatter/`

- `bibliography.bib` — BibTeX format. All references in IEEE style. Cited with `@key` syntax.
- `appendices.typ` — Optional appendices (survey forms, source code, user manuals)

### `.ctu-thesisrc`

Project-specific configuration overrides. Created by `ctu-thesis config init`. Takes precedence over `~/.ctu-thesis/config`.

## Adding figures

Place images in `images/` and reference them in your chapters:

```typst
// In any chapter .typ file
#figure(
  image("images/chapter1/system-architecture.png", width: 80%),
  caption: [System Architecture Diagram],
) <fig-architecture>

Referenced as @fig-architecture.
```

Images are automatically numbered sequentially within each chapter (Figure 1.1, 1.2, etc.).

## Adding tables

```typst
#figure(
  table(
    columns: 3,
    [Method], [Precision], [Recall],
    [SVM], [0.92], [0.88],
    [CNN], [0.95], [0.91],
  ),
  caption: [Model Performance Comparison],
) <tab-performance>
```

Tables are numbered sequentially within each chapter (Table 1.1, 1.2, etc.).

## Adding citations

Edit `backmatter/bibliography.bib` with your references:

```bibtex
@article{smith2023ml,
  author  = {Smith, John and Johnson, Mary},
  title   = {Machine Learning in E-commerce},
  journal = {IEEE Trans. Software Eng.},
  volume  = {45},
  number  = {3},
  pages   = {123--135},
  year    = {2023}
}
```

Cite in text:

```typst
According to @smith2023ml, the system...
Several studies @smith2023ml @lee2024 have shown...
```

Minimum 15 references required. See [Guidelines: Citations](10-guidelines-citations.md).
