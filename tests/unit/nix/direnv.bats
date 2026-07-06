#!/usr/bin/env bats

setup() {
    load "$BATS_LIB_PATH/bats-support/load"
    load "$BATS_LIB_PATH/bats-assert/load"
    load "$BATS_LIB_PATH/bats-file/load"
}

@test "file exists" {
    assert_file_exists nix/direnv.sh
}

@test "has shellcheck directive" {
    run grep -q '# shellcheck shell=bash' nix/direnv.sh
    assert_success
}

@test "watches flake.nix for changes" {
    run grep -q 'watch_file flake.nix' nix/direnv.sh
    assert_success
}

@test "watches flake.lock for changes" {
    run grep -q 'watch_file flake.lock' nix/direnv.sh
    assert_success
}

@test "watches dev.sh for changes" {
    run grep -q 'watch_file dev.sh' nix/direnv.sh
    assert_success
}

@test "watches lefthook-xmllint.sh for changes" {
    run grep -q 'watch_file lefthook-xmllint.sh' nix/direnv.sh
    assert_success
}

@test "watches nix/lefthook-nix-no-embedded-shell.sh for changes" {
    run grep -q 'watch_file nix/lefthook-nix-no-embedded-shell.sh' nix/direnv.sh
    assert_success
}

@test "contains use flake" {
    run grep -q 'use flake' nix/direnv.sh
    assert_success
}

@test "does not contain shell functions" {
    run grep -E '^\s*[a-zA-Z_][a-zA-Z_0-9]*\s*\(\)' nix/direnv.sh
    assert_failure
}
