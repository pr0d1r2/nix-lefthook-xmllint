# Contributing

## Prerequisites

- [Nix](https://nixos.org/) with flakes enabled
- [direnv](https://direnv.net/) (recommended)

## Dev environment setup

The project uses a Nix flake devShell. The recommended way to enter it is via direnv:

```bash
cd nix-lefthook-xmllint
direnv allow    # first time only — approves .envrc
```

direnv automatically loads the devShell when you enter the directory. The `.envrc` sources `nix/direnv.sh`, which watches `flake.nix`, `flake.lock`, `dev.sh`, `lefthook-xmllint.sh`, and `nix/lefthook-nix-no-embedded-shell.sh` for changes and reloads the shell when any of them change.

If you are not using direnv, enter the shell manually:

```bash
nix develop
```

The devShell provides all build and lint tools, sets `BATS_LIB_PATH` for the test libraries, and runs `lefthook install` on first entry (when `.git/hooks/pre-commit` is missing).

## Running tests

Unit tests use [bats](https://github.com/bats-core/bats-core) with bats-support, bats-assert, and bats-file helper libraries.

Run all tests:

```bash
bats tests/unit/
```

Run a single test file:

```bash
bats tests/unit/lefthook-xmllint.bats
```

`BATS_LIB_PATH` is set automatically by the devShell. If tests fail with load errors, verify you are inside the Nix shell.

## Environment variables

| Variable | Default | Description |
|---|---|---|
| `LEFTHOOK_XMLLINT_TIMEOUT` | `30` | Timeout in seconds for the xmllint lefthook command. |
| `BATS_LIB_PATH` | set by devShell | Path to bats helper libraries. |

## Lefthook hooks

All checks run on both pre-commit (staged files) and pre-push (push files). Hooks run in parallel.

### Local commands

| Hook | Description |
|---|---|
| xmllint | Validates `.xml` files with `xmllint --noout`. Uses `timeout` with `LEFTHOOK_XMLLINT_TIMEOUT` (default 30s). |

### Remote checks

The following checks are pulled in as lefthook remotes:

| Hook | Description |
|---|---|
| nixfmt | Formats Nix files. |
| shellcheck | Lints shell scripts for common issues. |
| shfmt | Checks shell script formatting. |
| statix | Static analysis for Nix files. |
| deadnix | Finds unused code in Nix files. |
| nix-no-embedded-shell | Ensures Nix files do not contain embedded shell scripts. |
| bats-parse | Parses bats test files for syntax errors. |
| bats-unit | Runs bats unit tests for changed files. |
| yamllint | Lints YAML files. |
| nix-flake-check | Runs `nix flake check`. |
| typos | Spell-checks source files. |
| trailing-whitespace | Detects trailing whitespace. |
| missing-final-newline | Ensures files end with a newline. |
| git-conflict-markers | Detects leftover conflict markers. |
| editorconfig-checker | Validates files against `.editorconfig` rules. |
| git-no-local-paths | Ensures no local filesystem paths leak into tracked files. |
| file-size-check | Enforces per-extension file size limits (see `config/lefthook/file_size_limits.yml`). |

Hooks are installed automatically by `lefthook install`, which the devShell runs on first entry. To reinstall manually:

```bash
lefthook install
```
