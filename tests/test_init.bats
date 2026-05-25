#!/usr/bin/env bats

load test_helper

@test "init: creates project directory with required files" {
  ctu_create_minimal_templates
  cd "$TEST_TEMP"
  run ctu init test-project \
    --lang=en --type=bachelor --title="Test Thesis" \
    --student="Jane Doe" --id="B2026001" --class="DI2296A1" \
    --advisor="Dr. Smith" --advisor-title="Dr." \
    --non-interactive
  [[ "$status" -eq 0 ]]
  [[ -d "$TEST_TEMP/test-project" ]]
  [[ -f "$TEST_TEMP/test-project/main.typ" ]]
  [[ -f "$TEST_TEMP/test-project/info.typ" ]]
  [[ -f "$TEST_TEMP/test-project/.ctu-thesisrc" ]]
}

@test "init: refuses to overwrite without --force" {
  ctu_create_minimal_templates
  cd "$TEST_TEMP"
  mkdir -p "$TEST_TEMP/existing-project"
  run ctu init existing-project --lang=en --type=bachelor --non-interactive
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"already exists"* ]]
}

@test "init: overwrites with --force" {
  ctu_create_minimal_templates
  cd "$TEST_TEMP"
  mkdir -p "$TEST_TEMP/existing-force"
  run ctu init existing-force --lang=en --type=bachelor --non-interactive --force
  [[ "$status" -eq 0 ]]
}

@test "init: rejects invalid language" {
  ctu_create_minimal_templates
  cd "$TEST_TEMP"
  run ctu init test-bad --lang=de --type=bachelor --non-interactive
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Unsupported language"* ]]
}

@test "init: replaces placeholders in info.typ" {
  ctu_create_minimal_templates
  cd "$TEST_TEMP"
  run ctu init test-subst \
    --lang=en --type=bachelor --title="My Thesis" \
    --student="Alice" --id="B999" --class="DI01" \
    --advisor="Dr. X" --advisor-title="Dr." \
    --non-interactive
  [[ "$status" -eq 0 ]]
  local infofile="$TEST_TEMP/test-subst/info.typ"
  grep -q '"Alice"' "$infofile"
  grep -q '"B999"' "$infofile"
  ! grep -q '{{STUDENT_NAME}}' "$infofile"
  ! grep -q '{{STUDENT_ID}}' "$infofile"
}

@test "init: creates .ctu-thesisrc with correct values" {
  ctu_create_minimal_templates
  cd "$TEST_TEMP"
  run ctu init test-rc \
    --lang=vi --type=bachelor --title="LV" \
    --student="Bob" --id="B111" --class="DI02" \
    --advisor="TS. Y" --advisor-title="TS." \
    --non-interactive
  [[ "$status" -eq 0 ]]
  local rcfile="$TEST_TEMP/test-rc/.ctu-thesisrc"
  grep -q 'lang=vi' "$rcfile"
  grep -q 'name=Bob' "$rcfile"
  grep -q 'id=B111' "$rcfile"
}

@test "init: uses config defaults when flags omitted" {
  ctu_create_minimal_templates
  cd "$TEST_TEMP"
  ctu config set student.name "ConfigUser"
  ctu config set student.id "C123"
  run ctu init test-defaults --lang=en --type=bachelor --non-interactive
  [[ "$status" -eq 0 ]]
  grep -q '"ConfigUser"' "$TEST_TEMP/test-defaults/info.typ"
  grep -q '"C123"' "$TEST_TEMP/test-defaults/info.typ"
}
