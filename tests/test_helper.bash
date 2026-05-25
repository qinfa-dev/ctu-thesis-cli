#!/usr/bin/env bash
# Setup/teardown helpers for bats tests

setup() {
  TEST_TEMP="$(mktemp -d)"
  CTU_HOME="${TEST_TEMP}/.ctu-thesis"
  CTU_CONFIG="${CTU_HOME}/config"
  CTU_TEMPLATES_DIR="${CTU_HOME}/templates"
  CTU_CACHE_DIR="${CTU_HOME}/cache"
  export CTU_HOME CTU_CONFIG CTU_TEMPLATES_DIR CTU_CACHE_DIR
  mkdir -p "$CTU_HOME/bin" "$CTU_HOME/lib/commands" "$CTU_TEMPLATES_DIR" "$CTU_CACHE_DIR"

  # Copy CLI source into test CTU_HOME
  cp "$BATS_TEST_DIRNAME/../lib/version.sh" "$CTU_HOME/lib/"
  cp "$BATS_TEST_DIRNAME/../lib/core.sh" "$CTU_HOME/lib/"
  cp "$BATS_TEST_DIRNAME/../lib/commands/"*.sh "$CTU_HOME/lib/commands/" 2>/dev/null || true
  cp "$BATS_TEST_DIRNAME/../bin/ctu-thesis" "$CTU_HOME/bin/ctu-thesis"
  chmod +x "$CTU_HOME/bin/ctu-thesis"

  # Copy template files if they exist
  if [[ -d "$BATS_TEST_DIRNAME/../templates" ]] && [[ -f "$BATS_TEST_DIRNAME/../templates/main.typ" ]]; then
    cp -r "$BATS_TEST_DIRNAME/../templates/"* "$CTU_TEMPLATES_DIR/"
  fi
}

teardown() {
  rm -rf "${TEST_TEMP:-/tmp/ctu-test-not-set}"
}

# Helper: invoke ctu-thesis entrypoint via bash
ctu() {
  HOME="$TEST_TEMP" bash "$CTU_HOME/bin/ctu-thesis" "$@"
}

# Helper: create minimal templates for testing
ctu_create_minimal_templates() {
  mkdir -p "$CTU_TEMPLATES_DIR"
  cat > "$CTU_TEMPLATES_DIR/main.typ" << 'TYPEOF'
#let lang = "{{LANG}}"
TYPEOF
  cat > "$CTU_TEMPLATES_DIR/info.typ" << 'TYPEOF'
#let info = (
  en: ( student: ( name: "{{STUDENT_NAME}}", id: "{{STUDENT_ID}}" ) ),
  vi: ( student: ( name: "{{STUDENT_NAME}}", id: "{{STUDENT_ID}}" ) ),
)
#let settings = ( primary_lang: "{{LANG}}" )
TYPEOF
  cat > "$CTU_TEMPLATES_DIR/compliance.json" << 'JSONEOF'
{"format":{"font":"Times New Roman","font_size":"13pt"}}
JSONEOF
}
