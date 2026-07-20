#!/usr/bin/env bats

setup() {
    bats_load_library bats-support
    bats_load_library bats-assert
    bats_load_library bats-file

    TMPDIR="$(mktemp -d)"
}

teardown() {
    rm -rf "$TMPDIR"
}

@test "file exists" {
    assert_file_exists nix/lefthook-nix-no-embedded-shell.sh
}

@test "contains SCANNER placeholder" {
    run grep -q '@SCANNER@' nix/lefthook-nix-no-embedded-shell.sh
    assert_success
}

@test "sets SCANNER variable from placeholder" {
    run grep -q 'SCANNER="@SCANNER@"' nix/lefthook-nix-no-embedded-shell.sh
    assert_success
}

@test "has shellcheck directive" {
    run grep -q '# shellcheck shell=bash' nix/lefthook-nix-no-embedded-shell.sh
    assert_success
}

@test "disables SC2034 for SCANNER used by concatenated upstream script" {
    run grep -q '# shellcheck disable=SC2034' nix/lefthook-nix-no-embedded-shell.sh
    assert_success
}

@test "does not contain shell functions" {
    run grep -E '^\s*[a-zA-Z_][a-zA-Z_0-9]*\s*\(\)' nix/lefthook-nix-no-embedded-shell.sh
    assert_failure
}

@test "SCANNER is set to substituted value" {
    sed 's|@SCANNER@|/test/scanner.sh|' nix/lefthook-nix-no-embedded-shell.sh > "$TMPDIR/test.sh"
    run bash -c 'source "$1"; echo "$SCANNER"' -- "$TMPDIR/test.sh"
    assert_success
    assert_output "/test/scanner.sh"
}
