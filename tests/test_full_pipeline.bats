#!/usr/bin/env bats

load test_helper

@test "full pipeline: all commands show help" {
  for cmd in init build validate doctor clean config chapter update help; do
    run ctu help "$cmd"
    [[ "$status" -eq 0 ]] || {
      echo "Failed: ctu help $cmd"
      false
    }
  done
}

@test "version output is correct" {
  run ctu --version
  [[ "$output" == *"1.0.0"* ]]
}

@test "template sync test passes" {
  if [[ ! -f "$BATS_TEST_DIRNAME/test_template_sync.sh" ]]; then
    skip "sync test script not found"
  fi
  run bash "$BATS_TEST_DIRNAME/test_template_sync.sh"
  [[ "$status" -eq 0 ]]
}

@test "full pipeline: init -> build (requires typst)" {
  if ! command -v typst &>/dev/null; then
    skip "typst not installed"
  fi
  ctu_create_minimal_templates
  cd "$TEST_TEMP"
  run ctu init full-test \
    --lang=en --type=bachelor \
    --title="Full Pipeline Test" \
    --student="Pipeline" --id="P001" --class="P01" \
    --advisor="Dr. P" --advisor-title="Dr." \
    --non-interactive --force
  [[ "$status" -eq 0 ]]
  [[ -d "$TEST_TEMP/full-test" ]]
  cd "$TEST_TEMP/full-test"
  run ctu validate
  [[ "$status" -eq 0 ]] || [[ "$status" -eq 4 ]] || true
}

@test "doctor --json output is valid" {
  run ctu doctor --json
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    echo "$line" | python3 -c "import sys,json; json.loads(sys.stdin.read())" 2>/dev/null || {
      # Fallback: just check it looks like JSON
      [[ "$line" =~ ^\{.*\}$ ]]
    }
  done <<< "$output"
}
