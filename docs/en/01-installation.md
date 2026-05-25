# 01 - Installation

## Prerequisites

| Dependency | Minimum Version | Purpose |
|-----------|----------------|---------|
| **Bash** | 4.2+ | Runtime shell |
| **Typst** | 0.12.0+ | PDF compilation (`build` command) |
| **curl** | any | Template download (`install`/`update`) |
| **Times New Roman** font | — | CTU-required font (optional; Typst falls back if missing) |

### Verify Bash version

```bash
bash --version
# GNU bash, version 5.2.15  (or higher)
```

### Install Typst

```bash
# Linux (via official binary)
curl -fsSL https://github.com/typst/typst/releases/latest/download/typst-x86_64-unknown-linux-musl.tar.xz | tar xJ
sudo mv typst-x86_64-unknown-linux-musl/typst /usr/local/bin/

# macOS (via Homebrew)
brew install typst

# Or download from: https://github.com/typst/typst/releases
```

Verify:

```bash
typst --version
# typst 0.12.0 (or higher)
```

### Install Times New Roman (Linux)

```bash
# Ubuntu/Debian
sudo apt install ttf-mscorefonts-installer

# Fedora
sudo dnf install curl cabextract xorg-x11-font-utils
rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm

# Arch
paru -S ttf-ms-fonts
```

## Install CTU Thesis CLI

### One-liner (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/qinfa-dev/ctu-thesis-cli/main/install.sh | bash
```

This downloads the CLI binary to `~/.local/bin/` and the template cache to `~/.ctu-thesis/templates/`.

### Manual install

```bash
git clone https://github.com/qinfa-dev/ctu-thesis-cli
cd ctu-thesis-cli
make install
```

### Verify installation

```bash
ctu-thesis --version
# ctu-thesis v2.0.0

ctu-thesis help
# Shows command reference
```

## Install locations

```
~/.local/bin/ctu-thesis          # CLI executable
~/.ctu-thesis/templates/         # Template cache (used by `init`)
~/.ctu-thesis/config             # Global user config
```

## PATH setup

If `ctu-thesis` is not found after install, add this to `~/.bashrc` or `~/.zshrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Then reload:

```bash
source ~/.bashrc  # or ~/.zshrc
```

## Shell completion

To enable tab-completion, source the completion script:

```bash
# Bash
source <(ctu-thesis completion bash)
echo 'source <(ctu-thesis completion bash)' >> ~/.bashrc

# Zsh
source <(ctu-thesis completion zsh)
echo 'source <(ctu-thesis completion zsh)' >> ~/.zshrc
```

## Uninstall

```bash
rm -rf ~/.ctu-thesis ~/.local/bin/ctu-thesis
# Optionally remove from PATH in ~/.bashrc
```
