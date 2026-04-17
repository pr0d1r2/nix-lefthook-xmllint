# nix-lefthook-xmllint

[![CI](https://github.com/pr0d1r2/nix-lefthook-xmllint/actions/workflows/ci.yml/badge.svg)](https://github.com/pr0d1r2/nix-lefthook-xmllint/actions/workflows/ci.yml)

> This code is LLM-generated and validated through an automated integration process using [lefthook](https://github.com/evilmartians/lefthook) git hooks, [bats](https://github.com/bats-core/bats-core) unit tests, and GitHub Actions CI.

Lefthook-compatible [xmllint](https://gitlab.gnome.org/GNOME/libxml2) wrapper, packaged as a Nix flake.

Filters `.xml` files from staged arguments and validates XML syntax. Exits 0 when no matching files are found.

## Usage

### Option A: Lefthook remote (recommended)

Add to your `lefthook.yml` — no flake input needed, just the wrapper binary in your devShell:

```yaml
remotes:
  - git_url: https://github.com/pr0d1r2/nix-lefthook-xmllint
    ref: main
    configs:
      - lefthook-remote.yml
```

### Option B: Flake input

Add as a flake input:

```nix
inputs.nix-lefthook-xmllint = {
  url = "github:pr0d1r2/nix-lefthook-xmllint";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Add to your devShell:

```nix
nix-lefthook-xmllint.packages.${pkgs.stdenv.hostPlatform.system}.default
```

Add to `lefthook.yml`:

```yaml
pre-commit:
  commands:
    xmllint:
      glob: "*.xml"
      run: timeout ${LEFTHOOK_XMLLINT_TIMEOUT:-30} lefthook-xmllint {staged_files}
```

### Configuring timeout

The default timeout is 30 seconds. Override per-repo via environment variable:

```bash
export LEFTHOOK_XMLLINT_TIMEOUT=60
```

## Development

The repo includes an `.envrc` for [direnv](https://direnv.net/) — entering the directory automatically loads the devShell with all dependencies:

```bash
cd nix-lefthook-xmllint  # direnv loads the flake
bats tests/unit/
```

If not using direnv, enter the shell manually:

```bash
nix develop
bats tests/unit/
```

## License

MIT
