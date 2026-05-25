# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability in this project, please:

1. **Do not** open a public issue
2. Report it privately to the maintainers via GitHub's Security Advisory: https://github.com/ngtphat-towa/ctu-thesis-cli/security/advisories/new
3. Or contact the maintainers directly

### What to include
- Description of the vulnerability
- Steps to reproduce
- Affected version(s)
- Potential impact

We aim to respond within 48 hours and publish fixes promptly.

## Scope

Security concerns typically involve:
- The installer script (`install.sh`) — untrusted URL sources, command injection
- Template file generation — path traversal, file overwrite risks
- The `update` command — backup and restore integrity
- CI/CD workflows — secret exposure, supply chain risks
