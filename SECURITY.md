# Security Policy

## Supported Versions

`dbt-checks` is currently under active development.

Security fixes and compatibility updates are generally applied to the latest released versions.

| Version | Supported |
| --- | --- |
| Latest release | ✅ |
| Older releases | ⚠️ Best effort |

---

# Reporting a Vulnerability

If you discover a security vulnerability, please report it privately.

Please do **not** open a public GitHub issue for security-related vulnerabilities.

Instead, contact the maintainers with:

- a description of the issue
- reproduction steps
- affected versions
- potential impact
- any suggested mitigations (if available)

---

# Response Process

The maintainers will try to:

1. acknowledge the report
2. investigate the issue
3. validate the impact
4. prepare a fix if necessary
5. publish a patched release

Response times may vary depending on project availability and severity.

---

# Scope

Security reports may include issues related to:

- SQL injection risks
- unsafe SQL rendering
- dependency vulnerabilities
- adapter-specific security issues
- unsafe macro behavior
- package supply-chain concerns

---

# Disclosure Policy

Please avoid publicly disclosing vulnerabilities until:
- the issue has been investigated
- a fix has been prepared when possible
- maintainers have had reasonable time to respond

Responsible disclosure helps protect users of the package.

---

# Dependency Security

`dbt-checks` aims to minimize external dependencies whenever possible.

Current compatibility and dependency information can be found in:
- `packages.yml`
- project release notes
- CI configuration

---

# Best-effort Security Notice

`dbt-checks` is an open-source project maintained on a best-effort basis.

While reasonable care is taken to improve package safety and reliability, no guarantees are provided regarding:
- fitness for a specific purpose
- absence of vulnerabilities
- compatibility with all environments

Users are responsible for validating package usage within their own infrastructure and security requirements.