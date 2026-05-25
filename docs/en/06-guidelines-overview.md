# 06 - Guidelines: Overview

> # ⚠️  DISCLAIMER — PLEASE READ
>
> **This is NOT an official CTU document.** It is a community interpretation of **Decision 4125/QĐ-ĐHCT** (August 6, 2024).
>
> - Formatting rules **vary by department** and **change without notice**.
> - **Always confirm** with your academic advisor and department office before final submission.
> - Found an error? [**Report it here.**](https://github.com/qinfa-dev/ctu-thesis-cli/issues)

## General requirements

### Document type

- **Thesis Type**: Graduation Thesis (Luận văn tốt nghiệp)
- **Degree**: Bachelor of Engineering in Information Technology
- **Language**: English or Vietnamese

### Page setup

| Element | Specification |
|---------|--------------|
| **Paper Size** | A4 (210mm x 297mm) |
| **Orientation** | Portrait |
| **Margins** | Left: 4.0 cm, Right: 2.5 cm, Top: 2.5 cm, Bottom: 2.5 cm |
| **Binding Edge** | Left side (4cm margin for binding) |

### Typography

| Element | Specification |
|---------|--------------|
| **Font Family** | Times New Roman |
| **Font Size** | 13 pt (main text) |
| **Line Spacing** | 1.2 (main text), 1.0 (tables, figures, references) |
| **Paragraph** | First-line indent: 1.0 cm, Justified alignment |

## Document structure

```
GRADUATION THESIS
├── FRONT MATTER (Roman numerals: i, ii, iii...)
│   ├── Cover Page (outer)
│   ├── Inner Cover Page
│   ├── Evaluation Page
│   ├── Acknowledgements
│   ├── Table of Contents
│   ├── List of Figures
│   ├── List of Tables
│   ├── List of Abbreviations
│   └── Abstract (200-350 words)
│
├── MAIN CONTENT (Arabic numerals: 1, 2, 3...)
│   ├── PART 1: INTRODUCTION
│   │   ├── 1. Context and Problem Statement
│   │   ├── 2. Related Work
│   │   ├── 3. Objectives and Scope
│   │   ├── 4. Research Content
│   │   └── 5. Thesis Outline
│   │
│   ├── PART 2: THESIS CONTENT
│   │   ├── CHAPTER 1: Background and Related Work
│   │   ├── CHAPTER 2: Design and Implementation
│   │   └── CHAPTER 3: Testing and Evaluation
│   │
│   └── PART 3: CONCLUSION AND FUTURE WORK
│       ├── I. Conclusion
│       └── II. Future Work
│
└── BACK MATTER
    ├── References (IEEE style)
    └── Appendices (optional)
```

## Minimum page requirements

| Section | Minimum Pages |
|---------|--------------|
| Introduction (Part 1) | 8-12 pages |
| Main Content (Part 2) | 30-50 pages |
| Conclusion (Part 3) | 5-8 pages |
| **Total Main Content** | **50-80 pages** |

## Heading styles

### Part headings

| Attribute | Value |
|-----------|-------|
| Format | Centered, bold, uppercase, 14pt |
| Spacing | 2cm above, 1cm below |
| Numbering | None |
| Example | `PART 1: INTRODUCTION` |

### Chapter headings (Level 1)

| Attribute | Value |
|-----------|-------|
| Format | Centered, bold, uppercase, 14pt |
| Spacing | 1.5cm above, 1cm below |
| Numbering | `CHAPTER 1:`, `CHAPTER 2:`, etc. |
| Example | `CHAPTER 1: BACKGROUND AND RELATED WORK` |

### Section headings (Level 2)

| Attribute | Value |
|-----------|-------|
| Format | Left-aligned, bold, uppercase, 13pt |
| Spacing | 0.6cm above and below |
| Numbering | `1.1`, `1.2`, etc. |
| Example | `1.1 RESEARCH MOTIVATION` |

### Subsection headings (Level 3)

| Attribute | Value |
|-----------|-------|
| Format | Left-aligned, bold, sentence case, 13pt |
| Spacing | 0.3cm above and below |
| Numbering | `1.1.1`, `1.1.2`, etc. |
| Example | `1.1.1 Problem Statement` |

### Sub-subsection headings (Level 4)

| Attribute | Value |
|-----------|-------|
| Format | Left-aligned, bold, sentence case, 13pt |
| Spacing | 0.3cm above and below |
| Numbering | `1.1.1.1`, `1.1.1.2`, etc. |

## Page numbering

### Front matter

| Attribute | Value |
|-----------|-------|
| Style | Lowercase Roman (i, ii, iii...) |
| Position | Bottom center |
| Start | From Table of Contents (page i) |
| Exclude | Cover pages |

### Main content

| Attribute | Value |
|-----------|-------|
| Style | Arabic (1, 2, 3...) |
| Position | Bottom center |
| Start | From Part 1 Introduction (page 1) |
| Header | Short thesis title (italic, 9pt) + horizontal rule |

## Headers and footers

### Header (main content only)

```
Short Thesis Title (max 50 characters, italic, 9pt)
_______________________________________________ (0.5pt rule)
```

### Footer (all pages)

```
_______________________________________________ (0.5pt rule)
                    Page Number
```

## Quick reference

```
Paper:     A4
Margins:   L:4cm, R:2.5cm, T:2.5cm, B:2.5cm
Font:      Times New Roman, 13pt
Spacing:   1.2 main text, 1.0 tables/figures/refs
Indent:    1cm first-line
```

```
Headings:
  Part:     14pt, Bold, Uppercase, Centered
  Chapter:  14pt, Bold, Uppercase, Centered
  Section:  13pt, Bold, Uppercase, Left
  Subsec:   13pt, Bold, Sentence case, Left
```

```
Numbering:
  Front:    i, ii, iii, iv...
  Main:     1, 2, 3, 4...
  Chapters: CHAPTER 1, CHAPTER 2...
  Sections: 1.1, 1.2, 2.1, 2.2...
  Figures:  Figure 1.1, Figure 2.1...
  Tables:   Table 1.1, Table 2.1...
```

---

## Official References

These guidelines are based on the following official CTU documents:

| # | Document | Link |
|---|----------|------|
| 1 | **Decision 4125/QĐ-ĐHCT** (Aug 6, 2024) — University-wide thesis formatting regulations | Contact department |
| 2 | **College of ICT** — Graduation thesis requirements | [cict.ctu.edu.vn](https://cict.ctu.edu.vn/) |
| 3 | **CTU Learning Resource Center** — Binding specs & archival formats | [lrc.ctu.edu.vn](https://lrc.ctu.edu.vn/) |
| 4 | **IEEE Editorial Style Manual** | [ieeeauthorcenter.ieee.org](https://journals.ieeeauthorcenter.ieee.org/your-role-in-article-production/ieee-editorial-style-manual/) |

> **Note**: Specific department-level rules may supplement or override these general CTU-wide requirements. Always check with your department for the most current version.
