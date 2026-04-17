#!/usr/bin/env bats

setup() {
    load "$BATS_LIB_PATH/bats-support/load"
    load "$BATS_LIB_PATH/bats-assert/load"
    load "$BATS_LIB_PATH/bats-file/load"

    TEST_TEMP="$(mktemp -d)"
}

teardown() {
    rm -rf "$TEST_TEMP"
}

@test "exits 0 with no arguments" {
    run lefthook-xmllint
    assert_success
}

@test "exits 0 when no .xml files in arguments" {
    touch "$TEST_TEMP/file.txt"
    run lefthook-xmllint "$TEST_TEMP/file.txt"
    assert_success
}

@test "skips missing files silently" {
    run lefthook-xmllint "/nonexistent/file.xml"
    assert_success
}

@test "accepts valid XML file" {
    cat > "$TEST_TEMP/good.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<root>
  <item>hello</item>
</root>
EOF
    run lefthook-xmllint "$TEST_TEMP/good.xml"
    assert_success
}

@test "detects invalid XML" {
    cat > "$TEST_TEMP/bad.xml" << 'EOF'
<?xml version="1.0"?>
<root>
  <unclosed>
</root>
EOF
    run lefthook-xmllint "$TEST_TEMP/bad.xml"
    assert_failure
}

@test "filters non-.xml files from mixed input" {
    cat > "$TEST_TEMP/good.xml" << 'EOF'
<?xml version="1.0"?>
<root/>
EOF
    touch "$TEST_TEMP/file.txt"
    run lefthook-xmllint "$TEST_TEMP/good.xml" "$TEST_TEMP/file.txt"
    assert_success
}

@test "reports failure for any invalid file in batch" {
    cat > "$TEST_TEMP/good.xml" << 'EOF'
<?xml version="1.0"?>
<root/>
EOF
    cat > "$TEST_TEMP/bad.xml" << 'EOF'
<root><unclosed></root>
EOF
    run lefthook-xmllint "$TEST_TEMP/good.xml" "$TEST_TEMP/bad.xml"
    assert_failure
}
