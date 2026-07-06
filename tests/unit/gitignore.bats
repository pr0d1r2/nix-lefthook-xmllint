#!/usr/bin/env bats

setup() {
    load "$BATS_LIB_PATH/bats-support/load"
    load "$BATS_LIB_PATH/bats-assert/load"
}

@test ".gitignore contains PROMPT.md" {
    run grep -q "^PROMPT.md$" .gitignore
    assert_success
}

@test "PROMPT.md is not tracked by git" {
    run git ls-files --error-unmatch PROMPT.md
    assert_failure
}
