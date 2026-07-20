#!/usr/bin/env bats

setup() {
    bats_load_library bats-support
    bats_load_library bats-assert
    bats_load_library bats-file

    TMPDIR="$(mktemp -d)"
    git init "$TMPDIR/repo" >/dev/null 2>&1
    mkdir -p "$TMPDIR/repo/.git/hooks"
    touch "$TMPDIR/repo/.git/hooks/pre-commit"

    cp dev.sh "$TMPDIR/dev.sh"

    mkdir -p "$TMPDIR/bin"
    printf '#!%s\n' "$(command -v bash)" > "$TMPDIR/bin/lefthook"
    cat >> "$TMPDIR/bin/lefthook" <<'SH'
echo "lefthook $*" >> "$LEFTHOOK_LOG"
SH
    chmod +x "$TMPDIR/bin/lefthook"
}

teardown() {
    rm -rf "$TMPDIR"
}

@test "does not set BATS_LIB_PATH" {
    run grep -q 'BATS_LIB_PATH' dev.sh
    assert_failure
}

@test "does not contain placeholder variables" {
    run grep -q '@.*@' dev.sh
    assert_failure
}

@test "runs lefthook install when hooks are missing" {
    cd "$TMPDIR/repo"
    rm "$TMPDIR/repo/.git/hooks/pre-commit"
    # shellcheck disable=SC2030
    export PATH="$TMPDIR/bin:$PATH"
    # shellcheck disable=SC2030
    export LEFTHOOK_LOG="$TMPDIR/log"
    # shellcheck disable=SC1091
    source "$TMPDIR/dev.sh"
    assert_file_exists "$LEFTHOOK_LOG"
    run cat "$LEFTHOOK_LOG"
    assert_output "lefthook install"
}

@test "skips lefthook install when hooks exist" {
    cd "$TMPDIR/repo"
    # shellcheck disable=SC2031
    export PATH="$TMPDIR/bin:$PATH"
    # shellcheck disable=SC2031
    export LEFTHOOK_LOG="$TMPDIR/log"
    # shellcheck disable=SC1091
    source "$TMPDIR/dev.sh"
    assert_file_not_exists "$LEFTHOOK_LOG"
}
