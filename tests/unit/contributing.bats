#!/usr/bin/env bats

setup() {
    bats_load_library bats-support
    bats_load_library bats-assert
    bats_load_library bats-file
}

@test "CONTRIBUTING.md exists" {
    assert_file_exists CONTRIBUTING.md
}

@test "documents direnv setup" {
    run grep -q 'direnv' CONTRIBUTING.md
    assert_success
}

@test "documents .envrc" {
    run grep -q '\.envrc' CONTRIBUTING.md
    assert_success
}

@test "documents nix develop fallback" {
    run grep -q 'nix develop' CONTRIBUTING.md
    assert_success
}

@test "documents running tests with bats" {
    run grep -q 'bats tests/unit' CONTRIBUTING.md
    assert_success
}

@test "documents BATS_LIB_PATH" {
    run grep -q 'BATS_LIB_PATH' CONTRIBUTING.md
    assert_success
}

@test "documents LEFTHOOK_XMLLINT_TIMEOUT" {
    run grep -q 'LEFTHOOK_XMLLINT_TIMEOUT' CONTRIBUTING.md
    assert_success
}

@test "documents xmllint hook" {
    run grep -q 'xmllint' CONTRIBUTING.md
    assert_success
}

@test "documents shellcheck hook" {
    run grep -q 'shellcheck' CONTRIBUTING.md
    assert_success
}

@test "documents nixfmt hook" {
    run grep -q 'nixfmt' CONTRIBUTING.md
    assert_success
}

@test "documents statix hook" {
    run grep -q 'statix' CONTRIBUTING.md
    assert_success
}

@test "documents deadnix hook" {
    run grep -q 'deadnix' CONTRIBUTING.md
    assert_success
}

@test "documents yamllint hook" {
    run grep -q 'yamllint' CONTRIBUTING.md
    assert_success
}

@test "documents hooks run on both pre-commit and pre-push" {
    run grep -q 'pre-commit' CONTRIBUTING.md
    assert_success
    run grep -q 'pre-push' CONTRIBUTING.md
    assert_success
}

@test "documents lefthook install" {
    run grep -q 'lefthook install' CONTRIBUTING.md
    assert_success
}
