#!/usr/bin/env bats

setup() {
    bats_load_library bats-support
    bats_load_library bats-assert
}

@test ".envrc watches nix/direnv.sh for changes" {
    run grep -q "watch_file nix/direnv.sh" .envrc
    assert_success
}

@test ".envrc sources nix/direnv.sh" {
    run grep -q "source nix/direnv.sh" .envrc
    assert_success
}
