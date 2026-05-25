#!/usr/bin/env bats

load test_helper

@test "doctor: runs all checks" {
  run ctu doctor
  [[ "$output" == *"bash"* ]]
  [[ "$output" == *"typst"* ]]
}

@test "doctor: --json outputs valid JSON lines" {
  run ctu doctor --json
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    [[ "$line" =~ ^\{.*\}$ ]]
  done <<< "$output"
}

@test "doctor: reports font check status" {
  run ctu doctor --json
  [[ "$output" == *'font_times_new_roman'* ]]
}

@test "doctor: reports template cache status" {
  run ctu doctor --json
  [[ "$output" == *'template_cache'* ]]
}
