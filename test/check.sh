#!/bin/sh

set -e

source $(dirname $0)/helpers.sh

it_can_check_with_no_current_version() {
  check_key_from "no-version" "0.0.0" | jq -e "
    . == [{number: $(echo 0.0.0 | jq -R .)}]
  "
}

it_can_check_with_version() {
  check_key_from "some-version" "1.0.0" | jq -e "
    .[0] == {number: $(echo 1.0.0 | jq -R .)}
  "
}

run it_can_check_with_no_current_version
run it_can_check_with_version
