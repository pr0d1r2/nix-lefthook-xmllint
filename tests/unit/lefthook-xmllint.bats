#!/usr/bin/env bats

setup() {
    bats_load_library bats-support
    bats_load_library bats-assert
    bats_load_library bats-file

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

@test "accepts valid XML file with BOM" {
    printf '\xEF\xBB\xBF<?xml version="1.0" encoding="UTF-8"?>\n<root/>\n' \
        > "$TEST_TEMP/bom.xml"
    run lefthook-xmllint "$TEST_TEMP/bom.xml"
    assert_success
}

@test "rejects empty file (0 bytes)" {
    touch "$TEST_TEMP/empty.xml"
    run lefthook-xmllint "$TEST_TEMP/empty.xml"
    assert_failure
}

@test "rejects .xml file containing non-XML content" {
    echo "this is not xml at all" > "$TEST_TEMP/notxml.xml"
    run lefthook-xmllint "$TEST_TEMP/notxml.xml"
    assert_failure
}

@test "accepts very large valid XML file" {
    {
        printf '<?xml version="1.0"?>\n<root>\n'
        for i in $(seq 1 10000); do
            printf '  <item id="%d">content %d</item>\n' "$i" "$i"
        done
        printf '</root>\n'
    } > "$TEST_TEMP/large.xml"
    run lefthook-xmllint "$TEST_TEMP/large.xml"
    assert_success
}
