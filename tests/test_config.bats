#!/usr/bin/env bats

load test_helper

@test "config: set and get round-trip" {
  ctu config set test.key "hello world"
  run ctu config get test.key
  [[ "$output" == "hello world" ]]
}

@test "config: get nonexistent key returns error" {
  run ctu config get none.such_key
  [[ "$status" -eq 1 ]]
}

@test "config: list shows all keys" {
  ctu config set a.key "val1"
  ctu config set b.key "val2"
  run ctu config list
  [[ "$output" == *"a.key=val1"* ]]
  [[ "$output" == *"b.key=val2"* ]]
}

@test "config: unset removes key" {
  ctu config set temp.key "val"
  ctu config unset temp.key
  run ctu config get temp.key
  [[ "$status" -eq 1 ]]
}

@test "config: handles special characters in values" {
  ctu config set spec.key "hello = world & stuff"
  run ctu config get spec.key
  [[ "$output" == "hello = world & stuff" ]]
}

@test "config: empty config file does not crash" {
  rm -f "$CTU_CONFIG"
  touch "$CTU_CONFIG"
  run ctu config list
}
