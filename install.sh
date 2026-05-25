#!/usr/bin/env bash
set -euo pipefail

# CTU Thesis CLI — One-Liner Installer
# Usage: curl -fsSL <url>/install.sh | bash

CTU_HOME="${CTU_HOME:-$HOME/.ctu-thesis}"
CTU_VERSION="1.0.0"

echo "======================================"
echo " CTU Thesis CLI v${CTU_VERSION} Installer"
echo "======================================"
echo ""

# Check bash version
if [[ "${BASH_VERSINFO[0]}" -lt 4 ]] || { [[ "${BASH_VERSINFO[0]}" -eq 4 ]] && [[ "${BASH_VERSINFO[1]}" -lt 2 ]]; }; then
  echo "Error: bash 4.2+ required. Current: ${BASH_VERSION}" >&2
  exit 1
fi

# Check curl
if ! command -v curl &>/dev/null; then
  echo "Error: curl is required. Install it first." >&2
  exit 1
fi

# Resolve install source
REPO_URL="${CTU_REPO_URL:-https://raw.githubusercontent.com/qinfa-dev/ctu-thesis-cli/main}"

echo "Installing to: $CTU_HOME"
mkdir -p "$CTU_HOME/bin" "$CTU_HOME/lib/commands" "$CTU_HOME/templates" "$CTU_HOME/cache"

# Download core files
echo "Downloading core files..."
for f in version.sh core.sh; do
  curl -fsSL "$REPO_URL/lib/${f}" -o "$CTU_HOME/lib/${f}" || {
    echo "Error: failed to download lib/${f}" >&2
    exit 3
  }
done

# Download command files
echo "Downloading command modules..."
for cmd in init build validate doctor clean config chapter update help; do
  curl -fsSL "$REPO_URL/lib/commands/${cmd}.sh" -o "$CTU_HOME/lib/commands/${cmd}.sh" || {
    echo "Warning: could not download command: $cmd" >&2
  }
done

# Download entrypoint
echo "Downloading entrypoint..."
curl -fsSL "$REPO_URL/bin/ctu-thesis" -o "$CTU_HOME/bin/ctu-thesis" || {
  echo "Error: failed to download entrypoint" >&2
  exit 3
}
chmod +x "$CTU_HOME/bin/ctu-thesis"

# Download templates
echo "Downloading templates..."
TEMPLATE_FILES=(
  "compliance.json" "info.typ" "main.typ"
  "template/i18n.typ" "template/ctu-styles.typ"
  "frontmatter/cover.typ" "frontmatter/inner-cover.typ"
  "frontmatter/evaluation.typ" "frontmatter/acknowledgements.typ"
  "frontmatter/abstract.typ" "frontmatter/table-of-contents.typ"
  "frontmatter/list-of-figures.typ" "frontmatter/list-of-tables.typ"
  "frontmatter/abbreviations.typ"
  "chapters/part1-introduction.typ" "chapters/part2-content.typ" "chapters/part3-conclusion.typ"
  "chapters/part1/01-context.typ" "chapters/part1/02-related-work.typ"
  "chapters/part1/03-objectives.typ" "chapters/part1/04-methodology.typ"
  "chapters/part1/05-outline.typ" "chapters/part2/chapter1-background.typ"
  "chapters/part2/chapter1/01-background.typ"
  "chapters/part3/01-conclusion.typ" "chapters/part3/02-future-work.typ"
  "backmatter/bibliography.bib" "backmatter/appendices.typ"
  "images/logo/CTU_logo.png"
)

for f in "${TEMPLATE_FILES[@]}"; do
  local_dir=$(dirname "$CTU_HOME/templates/$f")
  mkdir -p "$local_dir"
  curl -fsSL "$REPO_URL/templates/${f}" -o "$CTU_HOME/templates/${f}" 2>/dev/null || {
    echo "Warning: could not download templates/${f}" >&2
  }
done

# Create symlink
SYMLINK_PATHS=("/usr/local/bin" "$HOME/.local/bin" "$HOME/bin")
for p in "${SYMLINK_PATHS[@]}"; do
  if [[ -d "$p" ]] && [[ -w "$p" ]]; then
    ln -sf "$CTU_HOME/bin/ctu-thesis" "$p/ctu-thesis" 2>/dev/null || true
    echo "Symlink created: $p/ctu-thesis"
    break
  fi
done

# Verify
echo ""
echo "Installation complete!"

if [[ -x "$CTU_HOME/bin/ctu-thesis" ]]; then
  "$CTU_HOME/bin/ctu-thesis" doctor 2>/dev/null || true
fi

echo ""
echo "To get started:"
echo "  ctu-thesis init my-thesis --lang=en"
echo "  cd my-thesis"
echo "  ctu-thesis build"
echo ""
echo "For help: ctu-thesis help"
