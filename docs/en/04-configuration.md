# 04 - Configuration

## Configuration layers

CTU Thesis CLI uses two layers of configuration:

| Layer | File | Scope | Overrides |
|-------|------|-------|-----------|
| **Global** | `~/.ctu-thesis/config` | All projects on this machine | — |
| **Project** | `<project>/.ctu-thesisrc` | This project only | Global |

---

## Global config (`~/.ctu-thesis/config`)

INI-style key=value file. Created automatically on first `ctu-thesis config set`.

```ini
# CTU Thesis CLI Global Configuration
student.name=Nguyen Van A
student.id=B2000001
student.class=DI20V8A1
student.major=Software Engineering
student.program=High-Quality Program
advisor.name=Dr. Tran Van B
advisor.title=Dr.
defaults.lang=en
```

### Setting values

```bash
ctu-thesis config set student.name "Nguyen Van A"
ctu-thesis config set student.id "B2000001"
ctu-thesis config set defaults.lang "vi"
```

### Reading values

```bash
ctu-thesis config get student.name
# Nguyen Van A
```

### Listing all

```bash
ctu-thesis config list
```

### Removing a value

```bash
ctu-thesis config unset student.class
```

---

## Project config (`.ctu-thesisrc`)

Created in the project root. Used to track project-specific overrides.

```bash
cd my-thesis
ctu-thesis config init
```

This copies your global defaults into `<project>/.ctu-thesisrc`. You can then edit the file directly to customize per-project settings.

```ini
# CTU Thesis CLI Project Configuration
student.name=Nguyen Van A
student.id=B2000001
```

---

## `info.typ` — Thesis metadata

The `info.typ` file in your project contains all thesis metadata. This is the **single source of truth** for your compile-time information.

### Structure

```typst
#let info = (
  en: (                          // English metadata
    student: (
      name: "Your Full Name",
      id: "B2000001",
      class: "DI20V8A1",
      major: "Software Engineering",
      program: "High-Quality Program",
    ),
    advisor: (
      name: "Dr. Advisor Name",
      title: "Dr.",
    ),
    thesis: (
      title: "Your Thesis Title",
      short_title: "Short Title",
      date: "May 2026",
      location: "Can Tho",
      degree: "BACHELOR OF ENGINEERING IN INFORMATION TECHNOLOGY",
    ),
    keywords: ("kw1", "kw2", "kw3", "kw4", "kw5"),
    committee: (
      chairman: "Dr. Chairman Name",
      reviewer: "Dr. Reviewer Name",
      advisor: "Dr. Advisor Name",
    ),
    abbreviations: (
      ("API", "Application Programming Interface"),
      ("CTU", "Can Tho University"),
    ),
  ),
  vi: (                          // Vietnamese metadata
    student: (
      name: "Your Full Name",
      id: "B2000001",
      class: "DI20V8A1",
      major: "Kỹ thuật Phần mềm",
      program: "Chương trình Chất lượng cao",
    ),
    advisor: (
      name: "Dr. Advisor Name",
      title: "TS.",
    ),
    thesis: (
      title: "Tên Luận Văn của Bạn",
      short_title: "Tên Rút Gọn",
      date: "Tháng 5, 2026",
      location: "Cần Thơ",
      degree: "KỸ SƯ CÔNG NGHỆ THÔNG TIN",
    ),
    keywords: ("kw1", "kw2", "kw3", "kw4", "kw5"),
    committee: (
      chairman: "TS. Tên Chủ Tịch",
      reviewer: "TS. Tên Phản Biện",
      advisor: "Dr. Advisor Name",
    ),
    abbreviations: (
      ("API", "Giao diện lập trình ứng dụng"),
      ("CTU", "Đại học Cần Thơ"),
    ),
  ),
)

#let settings = (
  primary_lang: "en",            // "en" or "vi"

  border_color: rgb(0, 51, 153),    // CTU Blue #003399
  accent_color: rgb(0, 83, 159),    // CTU Accent #00539F

  format: (
    font: "Times New Roman",
    font_size: 13pt,
    line_spacing: 1.2,
    margins: (
      left: 4cm,
      right: 2.5cm,
      top: 2.5cm,
      bottom: 2.5cm,
    ),
    paragraph_indent: 1cm,
    abstract_words: (200, 350),
  ),
)
```

### Key field descriptions

| Field | Required | Description |
|-------|----------|-------------|
| `student.name` | Yes | Your full name (appears on cover) |
| `student.id` | Yes | Student ID (B-prefixed) |
| `student.class` | Yes | Class code |
| `student.major` | Yes | Major name |
| `student.program` | No | Program type (e.g., High-Quality) |
| `advisor.name` | Yes | Advisor's full name |
| `advisor.title` | Yes | Academic title (Dr., Assoc. Prof., etc.) |
| `thesis.title` | Yes | Full thesis title (can be 2-3 lines) |
| `thesis.short_title` | Yes | Short title for page headers (max 50 chars) |
| `thesis.date` | Yes | Completion date |
| `thesis.location` | Yes | City name |
| `thesis.degree` | Yes | Degree name |
| `keywords` | Yes | 3-5 keywords |
| `committee` | Yes | Committee members |
| `abbreviations` | No | List of (abbr, definition) pairs |

---

## `compliance.json`

Located in the template cache and checked by `validate`. Mirrors the format values in `info.typ`. Do not edit manually unless you understand the implications.

```json
{
  "version": "1.0.0",
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
    "min_references": 15
  }
}
```
