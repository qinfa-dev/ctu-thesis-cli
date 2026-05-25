# Contributing to CTU Thesis CLI

## How to Contribute

### Reporting Bugs
If you find a bug, please create a new issue using the Bug Report template.
- Check existing issues to avoid duplicates
- Describe the bug clearly, including steps to reproduce
- Include your environment: OS, bash version, typst version, CLI version

### Requesting Features
If you have an idea for a new feature, please use the Feature Request template.
- Explain why the feature is needed
- Describe how it should work
- Mention if you're willing to implement it

### Submitting Changes (Pull Requests)
1. Fork the repository
2. Clone your fork locally
3. Create a new branch: `git checkout -b feature/my-feature`
4. Make your changes. Follow the project conventions:
   - **Bash scripts**: follow [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html), use `shellcheck`
   - **Typst files**: keep placeholders as `{{VARIABLE}}`, use consistent formatting
   - **Tests**: write bats tests for all new command behavior
5. Run tests: `make test` (requires bats-core)
6. Run lint: `make lint` (requires shellcheck)
7. Commit with clear messages: `git commit -m "feat: add feature description"`
8. Push to your fork: `git push origin feature/my-feature`
9. Open a Pull Request to the `main` branch

### Development Setup

```bash
git clone https://github.com/ngtphat-towa/ctu-thesis-cli
cd ctu-thesis-cli

# Install test deps
sudo apt-get install -y shellcheck
git clone --depth 1 https://github.com/bats-core/bats-core.git /tmp/bats-core
cd /tmp/bats-core && sudo ./install.sh /usr/local

# Run tests
make test

# Run linter
make lint

# Create distribution bundle
make bundle
```

## Style Guide
- All commands follow `ctu_<commandname>()` naming
- Private helper functions use `_ctu_<name>()` prefix
- Exit codes: 0=success, 1=error, 2=missing dep, 4=validation failed, 5=user cancelled
- Log messages use `ctu_log_info`, `ctu_log_ok`, `ctu_log_warn`, `ctu_log_error`
- Template files use `{{PLACEHOLDER}}` syntax for `init` substitution
- Chapter management uses `// -- CTU-THESIS-CHAPTERS-START --` marker regions in `main.typ`

## Questions?
Open a Discussion or Issue on GitHub.
