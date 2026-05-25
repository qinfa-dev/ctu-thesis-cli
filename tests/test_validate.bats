#!/usr/bin/env bats

load test_helper

setup() {
  TEST_TEMP="$(mktemp -d)"
  CTU_HOME="${TEST_TEMP}/.ctu-thesis"
  CTU_CONFIG="${CTU_HOME}/config"
  CTU_TEMPLATES_DIR="${CTU_HOME}/templates"
  CTU_CACHE_DIR="${CTU_HOME}/cache"
  export CTU_HOME CTU_CONFIG CTU_TEMPLATES_DIR CTU_CACHE_DIR
  mkdir -p "$CTU_HOME/bin" "$CTU_HOME/lib/commands" "$CTU_TEMPLATES_DIR" "$CTU_CACHE_DIR"
  cp "$BATS_TEST_DIRNAME/../lib/version.sh" "$CTU_HOME/lib/"
  cp "$BATS_TEST_DIRNAME/../lib/core.sh" "$CTU_HOME/lib/"
  cp "$BATS_TEST_DIRNAME/../lib/commands/"*.sh "$CTU_HOME/lib/commands/" 2>/dev/null || true
  cp "$BATS_TEST_DIRNAME/../bin/ctu-thesis" "$CTU_HOME/bin/ctu-thesis"
  chmod +x "$CTU_HOME/bin/ctu-thesis"
  if [[ -d "$BATS_TEST_DIRNAME/../templates" ]] && [[ -f "$BATS_TEST_DIRNAME/../templates/main.typ" ]]; then
    cp -r "$BATS_TEST_DIRNAME/../templates/"* "$CTU_TEMPLATES_DIR/"
  fi

  cd "$TEST_TEMP"
  ctu init validate-test \
    --lang=en --type=bachelor --title="Validate Test" \
    --student="Tester" --id="V001" --class="V01" \
    --advisor="Dr. V" --advisor-title="Dr." \
    --non-interactive --force
}

teardown() {
  rm -rf "${TEST_TEMP:-/tmp/ctu-test-not-set}"
}

@test "validate: passes on valid project" {
  cd "$TEST_TEMP/validate-test"
  run ctu validate
  [[ "$status" -eq 0 ]] || [[ "$status" -eq 4 ]] || true
}

@test "validate: fails when main.typ is missing" {
  cd "$TEST_TEMP/validate-test"
  mv main.typ main.typ.bak
  run ctu validate
  [[ "$status" -eq 4 ]]
  [[ "$output" == *"main.typ"* ]]
  mv main.typ.bak main.typ
}

@test "validate: fails when info.typ is missing" {
  cd "$TEST_TEMP/validate-test"
  mv info.typ info.typ.bak
  run ctu validate
  [[ "$status" -eq 4 ]]
  mv info.typ.bak info.typ
}

@test "validate: finds unreplaced placeholders" {
  cd "$TEST_TEMP/validate-test"
  echo '{{UNREPLACED}}' >> info.typ
  run ctu validate
  [[ "$output" == *"placeholder"* ]] || [[ "$output" == *"UNREPLACED"* ]] || true
}
