# 09 - Guidelines: Figures, Tables, Equations, Code

> # ⚠️  DISCLAIMER — PLEASE READ
>
> **This is NOT an official CTU document.** It is a community interpretation of **Decision 4125/QĐ-ĐHCT** (August 6, 2024).
>
> - Formatting rules **vary by department** and **change without notice**.
> - **Always confirm** with your academic advisor and department office before final submission.
> - Found an error? [**Report it here.**](https://github.com/qinfa-dev/ctu-thesis-cli/issues)

## Figures

### Numbering

Sequential within chapters: Figure 1.1, 1.2, 2.1, 2.2, etc.

### Caption format

```
Figure 1.1. System Architecture Diagram
```

Caption goes **below** the figure.

### Placement

| Attribute | Value |
|-----------|-------|
| Alignment | Centered on page |
| Caption position | Below figure (0.3cm gap) |
| Block spacing | 0.6cm before and after |

### Quality requirements

| Attribute | Value |
|-----------|-------|
| Minimum resolution | 300 DPI |
| Preferred format | Vector graphics (SVG, PDF) |
| Text in diagrams | Clear, readable |
| Appearance | Professional |

### Referencing in text

```
As shown in Figure 1.1, the system...
```

### Typst usage

```typst
#figure(
  image("images/chapter1/architecture.png", width: 80%),
  caption: [System Architecture Diagram],
) <fig-architecture>

Referenced as @fig-architecture.
```

---

## Tables

### Numbering

Sequential within chapters: Table 1.1, 1.2, 2.1, 2.2, etc.

### Caption format

```
Table 2.1. Performance Comparison Results
```

Caption goes **above** the table.

### Placement

| Attribute | Value |
|-----------|-------|
| Alignment | Centered on page |
| Caption position | Above table (0.3cm gap) |
| Block spacing | 0.6cm before and after |

### Formatting rules

| Rule | Description |
|------|-------------|
| Borders | Simple, no heavy lines |
| Header row | Bold |
| Text alignment | Left-align text, right-align numbers |
| Column widths | Consistent |

### Referencing in text

```
Table 2.1 shows the performance metrics...
```

### Typst usage

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

---

## Equations

### Numbering

Sequential within chapters: (1.1), (1.2), (2.1), etc.

### Format

```
    E = mc²                                    (1.1)
```

- Centered equation body
- Equation number right-aligned in parentheses
- 0.3cm space above and below

### Referencing in text

```
Equation (1.1) describes...
```

### Typst usage

```typst
$ E = m c^2 $ <eq-einstein>

Referenced as @eq-einstein.
```

---

## Code listings

### Formatting

| Attribute | Value |
|-----------|-------|
| Font | Courier New or Consolas, 10pt |
| Background | Light gray (#F5F5F5) |
| Border | 0.5pt gray |
| Padding | 0.3cm all sides |
| Line spacing | Single (1.0) |

### Syntax highlighting

Recommended but not required.

### Caption (optional)

```
Listing 2.1. Total Price Calculation Function
```

### Typst usage

```typst
```python
def calculate_total(items):
    """Calculate total price of items."""
    return sum(item.price for item in items)
```
```

---

## Algorithms

### Format

Pseudocode or structured text.

### Example

```
Algorithm 1: Binary Search
Input: Sorted array A, target value x
Output: Index of x in A, or -1 if not found

1: left ← 0
2: right ← length(A) - 1
3: while left ≤ right do
4:     mid ← ⌊(left + right) / 2⌋
5:     if A[mid] = x then
6:         return mid
7:     else if A[mid] < x then
8:         left ← mid + 1
9:     else
10:        right ← mid - 1
11: end while
12: return -1
```

---

## Technical diagrams

### Accepted types

- System architecture diagrams
- UML diagrams (class, sequence, use case)
- Entity-relationship diagrams (ERD)
- Flowcharts
- Network diagrams

### Recommended tools

- Draw.io (free, online)
- Lucidchart (free tier)
- PlantUML (free, text-based)
- Microsoft Visio

### Requirements

- Clear labels
- Consistent notation
- Professional appearance
- High resolution (300+ DPI for raster, vector preferred)

---

## Official References

- **Decision 4125/QĐ-ĐHCT** (Aug 6, 2024) — University-wide thesis formatting regulations (contact department)
- **College of ICT Website** — [cict.ctu.edu.vn](https://cict.ctu.edu.vn/)
- **CTU Learning Resource Center** — [lrc.ctu.edu.vn](https://lrc.ctu.edu.vn/)

> Always verify with your department for the most current requirements.
