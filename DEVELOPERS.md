# Developer Guide

This guide covers the tooling, automation, and workflows included in this repository.

## Getting Started

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install)
- [pre-commit](https://pre-commit.com/) — `pip install pre-commit` or `brew install pre-commit`
- [terraform-docs](https://terraform-docs.io/) — `brew install terraform-docs`
- [tflint](https://github.com/terraform-linters/tflint) — `brew install tflint`
- [checkov](https://www.checkov.io/) — `pip install checkov`

### Initial Setup

If this repository was created from the [terraform-azurerm-module-template](https://github.com/appvia/terraform-azurerm-module-template):

1. Install pre-commit hooks:

   ```bash
   pre-commit install
   pre-commit install --hook-type commit-msg
   ```

2. Replace the `<NAME>` placeholder in `README.md` with your module name.

3. On your first commit, the `init-from-template` pre-commit hook will automatically replace the `__REPO_NAME__` placeholder in the README banner URLs with your repository name. The commit will fail with a "files were modified" message — simply re-stage and commit again.

## Pre-commit Hooks

This repository uses [pre-commit](https://pre-commit.com/) for automated code quality checks. Hooks run automatically on every commit.

**Installation:**

```bash
pre-commit install
pre-commit install --hook-type commit-msg
```

**Run all hooks manually:**

```bash
pre-commit run --all-files
```

### Configured Hooks

The following hooks are configured in `.pre-commit-config.yaml`:

| Hook | Source | Purpose |
|------|--------|---------|
| `check-added-large-files` | pre-commit-hooks | Blocks files larger than 500KB |
| `check-case-conflict` | pre-commit-hooks | Detects filename case conflicts |
| `check-json` | pre-commit-hooks | Validates JSON syntax |
| `check-merge-conflict` | pre-commit-hooks | Detects unresolved merge conflict markers |
| `check-symlinks` | pre-commit-hooks | Checks for broken symlinks |
| `check-yaml` | pre-commit-hooks | Validates YAML syntax |
| `end-of-file-fixer` | pre-commit-hooks | Ensures files end with a newline |
| `pretty-format-json` | pre-commit-hooks | Auto-formats JSON with 2-space indent |
| `trailing-whitespace` | pre-commit-hooks | Removes trailing whitespace |
| `check-shebang-scripts-are-executable` | pre-commit-hooks | Ensures scripts with shebangs are executable |
| `check-executables-have-shebangs` | pre-commit-hooks | Ensures executable files have shebangs |
| `no-commit-to-branch` | pre-commit-hooks | Prevents direct commits to `main` |
| `mixed-line-ending` | pre-commit-hooks | Enforces LF line endings |
| `forbid-new-submodules` | pre-commit-hooks | Prevents adding git submodules |
| `gitleaks` | gitleaks | Scans for hardcoded secrets and credentials |
| `actionlint` | actionlint | Lints GitHub Actions workflow files |
| `check-renovate` | check-jsonschema | Validates `renovate.json` against its schema |
| `commitlint` | commitlint | Enforces [Conventional Commits](https://www.conventionalcommits.org/) format |
| `terraform_fmt` | pre-commit-terraform | Auto-formats Terraform files |
| `terraform_validate` | pre-commit-terraform | Validates Terraform configuration |
| `terraform_tflint` | pre-commit-terraform | Lints Terraform with TFLint (azurerm + terraform rulesets) |
| `terraform_checkov` | pre-commit-terraform | Security scanning with Checkov |
| `terraform_docs` | pre-commit-terraform | Auto-generates documentation from Terraform code |
| `shellcheck` | shellcheck-py | Lints shell scripts |
| `init-from-template` | local | Replaces banner URL placeholders with the repository name |

### Excluding/Skipping Checks

Prefer inline exclusions where possible so the reason is visible next to the code. Use global config files for patterns that apply across the entire repository.

**Checkov** — inline (preferred):

```hcl
resource "azurerm_storage_account" "example" {
  #checkov:skip=CKV_AZURE_206:Reason for skipping this check
  name = "example"
}
```

Global: add check IDs to the `skip-check` list in `.checkov.yml`.

**TFLint** — inline (preferred):

```hcl
# tflint-ignore: terraform_unused_declarations
variable "unused_but_required" {
```

Global: set `enabled = false` on the rule in `.tflint.hcl`.

**Gitleaks** — inline (preferred):

```bash
export API_KEY="not-a-real-secret" # gitleaks:allow
```

Global: add patterns to the `[allowlist]` section in `.gitleaks.toml`.

**Shellcheck** — inline (preferred):

```bash
# shellcheck disable=SC2086
echo $unquoted_variable
```

Global: add directives to `.shellcheckrc`.

**Pre-commit hooks** — per-hook file exclusions in `.pre-commit-config.yaml`:

```yaml
- id: check-json
  exclude: |
    (?x)^(
        path/to/excluded/file.json
    )$
```

One-off skip (not recommended for regular use): `SKIP=hook_id git commit -m "message"`

## Dependency Management

Two dependency update tools are configured - Dependabot is simpler and native to GitHub, but renovate allows more flexibility and wider range of dependency management capabilities:

### Dependabot

Configuration: `.github/dependabot.yml`

- Updates GitHub Actions and Terraform dependencies weekly (Mondays)
- Scans `/`, `/examples/*`, and `/modules/*` directories
- Groups updates by ecosystem to reduce PR noise
- Commit messages use Conventional Commits format (`chore(scope): ...`)

### Renovate

Configuration: `renovate.json`

- Updates pre-commit hooks, TFLint plugins, GitHub Actions, Terraform providers, and Terraform modules
- Groups related updates into single PRs
- Runs on early Monday schedule

## Updating Documentation

Terraform input/output/provider documentation is auto-generated using [terraform-docs](https://terraform-docs.io/).

- Configuration: `.terraform-docs.yml`
- Documentation is injected between `<!-- BEGIN_TF_DOCS -->` and `<!-- END_TF_DOCS -->` markers in README files
- Regenerate manually: `make documentation` or `terraform-docs .`
- The `terraform_docs` pre-commit hook regenerates docs automatically on each commit - you do not need to do this manually.

## CI/CD Workflows

### Terraform Validation

Configuration: `.github/workflows/terraform.yml`

- Triggers on push to `main` and pull requests targeting `main`
- Uses the shared `appvia/appvia-cicd-workflows` reusable workflow for module validation
- Includes concurrency control (cancels in-progress runs on new pushes)

### Release

Configuration: `.github/workflows/release.yml`

- Triggers on version tags (`v*`)
- Uses the shared `appvia/appvia-cicd-workflows` reusable workflow for GitHub releases
- Create a release by tagging: `git tag v1.0.0 && git push --tags`

## Makefile Targets

Run `make <target>` for common development tasks:

| Target | Description |
|--------|-------------|
| `make all` | Run init, validate, tests, lint, security, format, and documentation |
| `make init` | Run `terraform init` across all directories |
| `make validate` | Run `terraform validate` across root, modules, and examples |
| `make tests` | Run `terraform test` |
| `make lint` | Run TFLint across root, modules, and examples |
| `make security` | Run Checkov security scanning |
| `make format` | Run `terraform fmt` recursively |
| `make documentation` | Generate terraform-docs for all directories |
| `make clean` | Remove all `.terraform` directories |
