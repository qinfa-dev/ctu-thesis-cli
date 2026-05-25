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

  ctu_create_minimal_templates
  cd "$TEST_TEMP"
  ctu init chapter-test \
    --lang=en --type=bachelor --title="Chapter Test" \
    --student="Chap" --id="C001" --class="C01" \
    --advisor="Dr. C" --advisor-title="Dr." \
    --non-interactive --force

  mkdir -p "$TEST_TEMP/chapter-test/chapters"
  cat > "$TEST_TEMP/chapter-test/main.typ" << 'TYPEOF'
#set page(width: auto, height: auto)
#set heading(numbering: "1.1.1.1")

#include "chapters/part2-content.typ"

// -- CTU-THESIS-CHAPTERS-START --
#include "chapters/chapter01.typ"
// -- CTU-THESIS-CHAPTERS-END --
TYPEOF

  echo "= Chapter 01: Introduction" > "$TEST_TEMP/chapter-test/chapters/chapter01.typ"
}

teardown() {
  rm -rf "${TEST_TEMP:-/tmp/ctu-test-not-set}"
}

@test "chapter: list shows chapters" {
  cd "$TEST_TEMP/chapter-test"
  run ctu chapter list
  [[ "$output" == *"Introduction"* ]]
}

@test "chapter: add creates new chapter file and updates main.typ" {
  cd "$TEST_TEMP/chapter-test"
  run ctu chapter add "System Design"
  [[ "$status" -eq 0 ]]
  [[ -f "chapters/chapter02.typ" ]]
  grep -q "chapter02.typ" main.typ
}

@test "chapter: remove deletes chapter" {
  cd "$TEST_TEMP/chapter-test"
  run ctu chapter remove 1 --force
  [[ "$status" -eq 0 ]]
  [[ ! -f "chapters/chapter01.typ" ]]
}

@test "chapter: remove refuses on only chapter" {
  cd "$TEST_TEMP/chapter-test"
  run ctu chapter remove 1
  [[ "$output" == *"Cannot remove the only"* ]] || [[ "$status" -ne 0 ]]
}
