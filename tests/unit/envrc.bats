#!/usr/bin/env bats

setup() {
    load "$BATS_LIB_PATH/bats-support/load"
    load "$BATS_LIB_PATH/bats-assert/load"
}

@test ".envrc contains use flake" {
    run grep -q "use flake" .envrc
    assert_success
}

@test ".envrc watches flake.nix for changes" {
    run grep -q "watch_file flake.nix" .envrc
    assert_success
}

@test ".envrc watches flake.lock for changes" {
    run grep -q "watch_file flake.lock" .envrc
    assert_success
}

@test ".envrc watches dev.sh for changes" {
    run grep -q "watch_file dev.sh" .envrc
    assert_success
}

@test ".envrc watches nix/lefthook-nix-no-embedded-shell.sh for changes" {
    run grep -q "watch_file nix/lefthook-nix-no-embedded-shell.sh" .envrc
    assert_success
}
