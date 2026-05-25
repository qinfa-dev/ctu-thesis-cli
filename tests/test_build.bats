#!/usr/bin/env bats

load test_helper

@test "build: fails on non-project directory" {
  cd "$TEST_TEMP"
  run ctu build
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Not in a thesis project"* ]]
}

@test "build: help shows usage" {
  run ctu help build
  [[ "$output" == *"Usage"* ]]
  [[ "$output" == *"build"* ]]
}

@test "build: detects language from info.typ" {
  ctu_create_minimal_templates
  cd "$TEST_TEMP"
  ctu init build-project --lang=vi --type=bachelor --non-interactive --force
  cd "$TEST_TEMP/build-project"

  # Create a minimal compilable main.typ (no imports needed for simple compile)
  cat > main.typ << 'TYPEOF'
#set page(width: auto, height: auto)
#set text(font: "Times New Roman", size: 13pt)
Hello
TYPEOF

  # Verify language detection
  local lang_detected
  lang_detected=$(grep -oP 'primary_lang:\s*"\K[^"]+' info.typ)
  [[ "$lang_detected" == "vi" ]]
}
