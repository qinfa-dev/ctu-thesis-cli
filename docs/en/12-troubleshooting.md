# 12 - Troubleshooting

## Typst not found

**Symptom**: `ctu-thesis build` fails with "typst: command not found"

**Fix**: Install Typst CLI.

```bash
# Linux
curl -fsSL https://github.com/typst/typst/releases/latest/download/typst-x86_64-unknown-linux-musl.tar.xz | tar xJ
sudo mv typst-x86_64-unknown-linux-musl/typst /usr/local/bin/

# macOS
brew install typst

# Verify
typst --version
```

Run `ctu-thesis doctor` to diagnose.

## PDF not generating

**Symptom**: Build runs but no PDF output.

**Checklist**:

1. Are you in a thesis project directory? Run `ls info.typ` to verify.
2. Check for Typst syntax errors in your `.typ` files — error messages appear in build output.
3. Try `ctu-thesis build --draft` for faster error discovery.
4. Run `ctu-thesis doctor` to check for missing dependencies.

## Images not showing

**Symptom**: Figures show blank or error in PDF.

**Fixes**:

1. Verify image paths — use relative paths from the chapter file:
   ```typst
   image("../images/chapter1/diagram.png")  // correct
   image("images/chapter1/diagram.png")       // wrong from chapters/
   ```
2. Ensure image file exists: `ls images/chapter1/diagram.png`
3. Supported formats: PNG, JPG, SVG, PDF
4. Files with spaces in names must be quoted: `image("images/my image.png")`

## Times New Roman font missing

**Symptom**: `ctu-thesis doctor` reports font not found, PDF uses fallback font.

**Fix**:

```bash
# Ubuntu/Debian
sudo apt install ttf-mscorefonts-installer

# Fedora
sudo dnf install curl cabextract xorg-x11-font-utils
rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm

# Arch
paru -S ttf-ms-fonts
```

Typst will use a fallback serif font if Times New Roman is unavailable, but your PDF may not match CTU requirements exactly. Install the font for full compliance.

## `ctu-thesis: command not found`

**Symptom**: Terminal cannot find `ctu-thesis`.

**Fixes**:

1. Re-run the install script:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/qinfa-dev/ctu-thesis-cli/main/install.sh | bash
   ```
2. Add `~/.local/bin` to PATH:
   ```bash
   echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```
3. Verify binary exists: `ls -la ~/.local/bin/ctu-thesis`

## Template cache is missing or corrupt

**Symptom**: `ctu-thesis init` fails or produces incomplete project.

**Fix**:

```bash
# Refresh template cache
ctu-thesis update --templates

# Or manually reinstall
rm -rf ~/.ctu-thesis/templates
curl -fsSL https://raw.githubusercontent.com/qinfa-dev/ctu-thesis-cli/main/install.sh | bash
```

## Validation fails with `ctu-thesis validate`

**Common causes and fixes**:

| Error | Fix |
|-------|-----|
| "Abstract word count: 180 (min: 200)" | Expand abstract to 200+ words |
| "Keywords count: 2 (min: 3)" | Add 1+ more keywords in `info.typ` |
| "Reference count: 8 (min: 15)" | Add more entries to `backmatter/bibliography.bib` |
| "Missing file: backmatter/bibliography.bib" | Create the file (re-run `init` or copy from template) |
| "Chapter file not found" | Run `ctu-thesis chapter list` to check register |

Use `ctu-thesis validate --fix` to auto-correct some issues.

## Bash version too old

**Symptom**: CLI crashes or behaves unexpectedly.

**Check**: `bash --version`

**Fix**: Upgrade to Bash 4.2+ (macOS ships with Bash 3.2; install via Homebrew):

```bash
# macOS
brew install bash
# Add to /etc/shells and set as default shell

# Linux — usually ships with >= 4.2 by default
```

## Build is slow

**Fixes**:

1. Use `--draft` mode during writing: `ctu-thesis build --draft`
2. Use `--watch` for continuous compilation (only recompiles changed files)
3. Reduce image sizes — avoid very large PNG/JPG files
4. Split large chapters into smaller files

## Still stuck?

Run the full diagnostic:

```bash
ctu-thesis doctor
```

This checks all dependencies, template cache, internet connectivity, and config files. Share the output when reporting issues.

For bugs and feature requests, open an issue at: https://github.com/qinfa-dev/ctu-thesis-cli/issues
