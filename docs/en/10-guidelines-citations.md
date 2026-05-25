# 10 - Guidelines: Citations and References

> # ⚠️  DISCLAIMER — PLEASE READ
>
> **This is NOT an official CTU document.** It is a community interpretation of **Decision 4125/QĐ-ĐHCT** (August 6, 2024).
>
> - Formatting rules **vary by department** and **change without notice**.
> - **Always confirm** with your academic advisor and department office before final submission.
> - Found an error? [**Report it here.**](https://github.com/qinfa-dev/ctu-thesis-cli/issues)

## Citation style

**IEEE Style** (numbered) is mandatory.

## In-text citations

### Basic formats

| Type | Format | Example |
|------|--------|---------|
| Single reference | `[1]` | `According to Smith [1], the system...` |
| Multiple references | `[1], [3], [5]` | `Several studies [1], [3], [5] have shown...` |
| Sequential references | `[1]-[4]` | `Recent work [1]-[4] demonstrates...` |

### Typst usage

```typst
// BibTeX key in backmatter/bibliography.bib
@smith2023ml

// Multiple citations
@smith2023ml @lee2024 @tran2024
```

## Reference list format

All references in `backmatter/bibliography.bib` (BibTeX).

### Journal article

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

Rendered as:

```
[1] J. Smith and M. Johnson, "Machine learning in e-commerce,"
    IEEE Trans. Software Eng., vol. 45, no. 3, pp. 123-135, Mar. 2023.
```

### Book

```bibtex
@book{brown2024,
  author    = {Brown, David},
  title     = {Software Engineering Principles},
  edition   = {3rd},
  address   = {New York, NY, USA},
  publisher = {McGraw-Hill},
  year      = {2024}
}
```

### Conference paper

```bibtex
@inproceedings{lee2023,
  author    = {Lee, Alice},
  title     = {Microservices Architecture},
  booktitle = {Proc. Int. Conf. Software Eng.},
  year      = {2023},
  pages     = {45--52}
}
```

### Website (use sparingly)

```bibtex
@misc{react2024,
  author       = {{Meta Platforms}},
  title        = {React Documentation},
  year         = {2024},
  howpublished = {[Online]. Available: \url{https://react.dev}},
  note         = {[Accessed: Jan. 1, 2026]}
}
```

## Requirements

| Requirement | Minimum |
|-------------|---------|
| Total references | 15 |
| Recent references (last 5 years) | 5 |
| Source types | Mix of journals, books, conferences |

## Validation

The `ctu-thesis validate` command checks:
- Reference count >= 15
- Bibliography file exists and is valid BibTeX
- References cited in text exist in bibliography

## Best practices

1. Start collecting references early — add to `bibliography.bib` as you research
2. Use Zotero, Mendeley, or EndNote with BibTeX export
3. Prefer journal and conference papers over websites
4. Include DOIs when available (add `doi = {...}` field)
5. Verify all citations appear in the reference list and vice versa
6. Sort references by order of appearance in text

## Useful resources

- IEEE Citation Guidelines: https://ieee-dataport.org/sites/default/files/analysis/27/IEEE%20Citation%20Guidelines.pdf
- IEEE Editorial Style Manual: https://journals.ieeeauthorcenter.ieee.org/your-role-in-article-production/ieee-editorial-style-manual/
- Zotero (free reference manager): https://www.zotero.org/
- BibTeX format reference: https://www.bibtex.com/g/bibtex-format/

---

## Official References

- **Decision 4125/QĐ-ĐHCT** (Aug 6, 2024) — Mandates IEEE citation style for CTU theses
- **IEEE Editorial Style Manual** — [ieeeauthorcenter.ieee.org](https://journals.ieeeauthorcenter.ieee.org/your-role-in-article-production/ieee-editorial-style-manual/)
- **IEEE Citation Guidelines** — [PDF](https://ieee-dataport.org/sites/default/files/analysis/27/IEEE%20Citation%20Guidelines.pdf)

> Always verify with your department for the most current requirements.
