#!/usr/bin/env bats

setup() {
    load "$BATS_LIB_PATH/bats-support/load"
    load "$BATS_LIB_PATH/bats-assert/load"
}

@test ".envrc watches nix/direnv.sh for changes" {
    run grep -q "watch_file nix/direnv.sh" .envrc
    assert_success
}

@test ".envrc sources nix/direnv.sh" {
    run grep -q "source nix/direnv.sh" .envrc
    assert_success
}
