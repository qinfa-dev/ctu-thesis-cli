# 02 - Quick Start

## In 5 minutes

### Step 1: Create a new thesis project

```bash
ctu-thesis init my-thesis --lang=en --title="My Research Topic"
```

This scaffolds a complete, compilable thesis project in the `my-thesis/` directory.

### Step 2: Enter the project directory

```bash
cd my-thesis
```

### Step 3: Edit your information

Open `info.typ` and replace the placeholder values with your actual information:

```typst
// info.typ — edit this first
en: (
  student: (
    name: "Nguyen Van A",        // Your full name
    id: "B2000001",              // Your student ID
    class: "DI20V8A1",           // Your class
    major: "Software Engineering",
    program: "High-Quality Program",
  ),
  advisor: (
    name: "Dr. Tran Van B",      // Your advisor
    title: "Dr.",
  ),
  thesis: (
    title: "My Research Topic",
    short_title: "Research Topic",
    date: "May 2026",
    location: "Can Tho",
    degree: "BACHELOR OF ENGINEERING IN INFORMATION TECHNOLOGY",
  ),
  keywords: (
    "keyword 1", "keyword 2", "keyword 3",
    "keyword 4", "keyword 5"
  ),
  // ...
)
```

### Step 4: Build your thesis

```bash
# Compile once
ctu-thesis build

# Watch mode (auto-recompile on save)
ctu-thesis build --watch
```

Your PDF is generated at the project root (`my-thesis.pdf` by default).

### Step 5: Start writing

Navigate to `chapters/part1/01-context.typ` and begin writing your introduction.

```bash
# List available chapters
ctu-thesis chapter list

# Add a new chapter
ctu-thesis chapter add "04-experiments.typ"
```

### Next steps

- [Configuration](04-configuration.md) — `info.typ` and `.ctu-thesisrc` in depth
- [Commands](03-commands.md) — all available CLI commands
- [Guidelines: Overview](06-guidelines-overview.md) — CTU formatting requirements
- [Troubleshooting](12-troubleshooting.md) — common issues and fixes
