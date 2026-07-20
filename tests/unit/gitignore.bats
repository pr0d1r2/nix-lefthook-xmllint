#!/usr/bin/env bats

setup() {
    bats_load_library bats-support
    bats_load_library bats-assert
}

@test ".gitignore contains PROMPT.md" {
    run grep -q "^PROMPT.md$" .gitignore
    assert_success
}

@test "PROMPT.md is not tracked by git" {
    run git ls-files --error-unmatch PROMPT.md
    assert_failure
}
