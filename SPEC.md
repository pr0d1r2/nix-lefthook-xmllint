## §D — Description

nix-lefthook-xmllint is a lefthook-compatible xmllint wrapper packaged as a Nix flake. It filters `.xml` files from lefthook's staged or pushed file arguments, validates each with `xmllint --noout`, and exits non-zero if any file is malformed. It is designed for Nix-based projects that use lefthook for git hook management and can be consumed either as a lefthook remote (recommended) or as a flake input added to a project's devShell. The project targets developers working on Linux (x86_64, aarch64) and macOS (x86_64, aarch64).

## §V — Invariants

1. `lefthook-xmllint` exits 0 when invoked with no arguments.
2. `lefthook-xmllint` exits 0 when no `.xml` files are present among arguments.
3. `lefthook-xmllint` silently skips files that do not exist on disk.
4. `lefthook-xmllint` exits non-zero if any XML file fails `xmllint --noout` validation.
5. All bats unit tests in `tests/unit/` must pass before merge.
6. The flake must evaluate and build on all four supported systems: `aarch64-darwin`, `x86_64-darwin`, `x86_64-linux`, `aarch64-linux`.
7. CI runs on both Linux (`ubuntu-latest`) and macOS (`macos-latest`).
8. Every lefthook command has a timeout (via `timeout` wrapper or `LEFTHOOK_XMLLINT_TIMEOUT` env var, default 30s).
9. All checks appear in both `pre-commit` and `pre-push` hooks.
10. Shell scripts must not contain functions; logic is split into separate scripts.
11. Shell scripts are invoked with `bash script.sh`, never `./script.sh`.
12. No embedded shell in nix files; shell logic is extracted to `.sh` files.
13. Every tracked file type has an assigned linter in `lefthook.yml` (local or via remotes).
14. Every implementation file has a 1-to-1 bats unit test file.

## §I — Interfaces

### CLI

| command | signature | description |
|---|---|---|
| `lefthook-xmllint` | `lefthook-xmllint [file...]` | Validates XML files. Returns exit 0 on success or no XML files; exit 1 if any file is invalid. |

### Nix flake outputs

| output | type | description |
|---|---|---|
| `packages.<system>.default` | derivation | `writeShellApplication` wrapping `lefthook-xmllint.sh` with `libxml2` on `PATH`. |
| `devShells.<system>.default` | devShell | Full dev environment: linter wrappers, bats, lefthook, libxml2. Runs `dev.sh` as `shellHook`. |
| `devShells.<system>.ci` | devShell | CI-only shell with same packages but no shell hook. Sets `BATS_LIB_PATH` directly. |

### Config files

| file | format | purpose |
|---|---|---|
| `lefthook.yml` | YAML | Root lefthook config. Defines xmllint commands and 17 remote check repos. |
| `lefthook-remote.yml` | YAML | Standalone config for consumers to include via lefthook `remotes:` directive. |
| `config/lefthook/file_size_limits.yml` | YAML | Per-extension file size limits (default 4096, lock 65536, nix 10240). |
| `.yamllint.yml` | YAML | yamllint config: disables `truthy` key check and `line-length` rule. |
| `.markdownlint.yml` | YAML | markdownlint config: disables `MD013` (line length). |
| `.editorconfig` | INI | Editor config: UTF-8, LF, 2-space indent, trim trailing whitespace, final newline. |

### Environment variables

| variable | default | description |
|---|---|---|
| `LEFTHOOK_XMLLINT_TIMEOUT` | `30` | Timeout in seconds for the xmllint lefthook command. |
| `BATS_LIB_PATH` | set by dev shell | Path to bats helper libraries (bats-support, bats-assert, bats-file). |

### Dev shell hook (`dev.sh`)

Sets `BATS_LIB_PATH` from the `@BATS_LIB_PATH@` placeholder (substituted by `flake.nix`). Conditionally runs `lefthook install` when `.git/hooks/pre-commit` is missing.

## §T — Tasks

| status | id | goal |
|---|---|---|
| `x` | T01 | Extend `.envrc` to watch `flake.nix`, `flake.lock`, and `dev.sh` for changes via `watch_file` directives as required by the direnv skill. |
| `x` | T02 | Harmonize bats library loading: `dev.bats` uses `load.bash` suffix while `lefthook-xmllint.bats` uses bare `load` — standardize to one form. |
| `.` | T10 | Add `load "$BATS_LIB_PATH/bats-file/load"` to `tests/unit/dev.bats` setup block — load only, no assertion changes. (§V14, §B3) |
| `.` | T11 | Add `load "$BATS_LIB_PATH/bats-file/load"` to `tests/unit/envrc.bats` setup block — same consistency fix. (§V14, §B3) |
| `.` | T12 | Refactor `dev.bats` test "runs lefthook install when hooks are missing" to use `assert_file_exists` from bats-file instead of `assert [ -f ... ]`. (§V14) |
| `decomposed` | T03 | Add `bats-file` library loading to `dev.bats` for consistency with `lefthook-xmllint.bats`. Decomposed into T10–T12. |
| `.` | T04 | Add edge-case tests for `lefthook-xmllint`: XML with BOM, empty file (0 bytes), file with `.xml` extension containing non-XML content, very large XML file. |
| `.` | T05 | Remove `PROMPT.md` from tracked files — it is a task prompt, not project documentation. |
| `.` | T06 | Extract the inline `SCANNER=` shell snippet in `flake.nix` (line 164-166) for the `lefthook-nix-no-embedded-shell` wrapper into a separate shell file to fully satisfy the nix modularity rule. |
| `.` | T07 | Add `nix/direnv.sh` extraction as referenced in the direnv skill doc — currently `.envrc` is a single `use flake` line with no watch infrastructure. |
| `.` | T08 | Set `BATS_LIB_PATH` consistently across both `ci` and `default` devShells — `ci` sets it as an env var while `default` sets it via `dev.sh` string substitution. |
| `.` | T09 | Add a `CONTRIBUTING.md` documenting the dev workflow: direnv setup, running tests, lefthook hook descriptions. |

## §B — Bugs / Known Issues

1. **`.envrc` missing `watch_file` directives.** The direnv skill requires `.envrc` to watch `flake.nix`, `flake.lock`, and any nix modules or shell fragments. Currently it is just `use flake`, so changes to `dev.sh` or nix modules do not trigger direnv reload.
2. ~~**Inconsistent bats library load syntax.**~~ Fixed: all bats files now use bare `load` (no `.bash` extension).
3. **`dev.bats` missing `bats-file` load.** Unlike `lefthook-xmllint.bats`, `dev.bats` does not load the `bats-file` library, even though both test files are in the same suite.
4. **Small embedded shell in `flake.nix`.** The `lefthook-nix-no-embedded-shell` wrapper (lines 163-167) prepends a `SCANNER=` variable via an inline Nix string before reading the external script. This technically violates the nix modularity rule, though it may be intentional to inject a Nix store path.
5. **`PROMPT.md` tracked in git.** This file contains the agent task prompt, not project documentation. It should either be removed or added to `.gitignore`.
6. **`ci` devShell `BATS_LIB_PATH` divergence.** The `ci` shell sets `BATS_LIB_PATH` as a `mkShell` env attribute, while `default` sets it via string substitution in `dev.sh`. If the bats library path format changes, both must be updated independently.
7. **`SPEC.md` exceeds default file-size-check limit (2026-07-04).** `SPEC.md` (6528 bytes) exceeded the 4096-byte default limit in `config/lefthook/file_size_limits.yml`, causing CI `file-size-check` to fail. Fixed by adding `md: 10240` extension entry to the file size limits config.
