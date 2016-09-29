set -e

source $(dirname $0)/helpers.sh

it_can_put_and_set_first_version() {

  version="1.2.3"

  put_key $key $version $PWD | jq -e "
    .version == {number: \"$version\"}
  "

  # switch back to master
  git -C $repo checkout master

  test -e $repo/some-file
  test "$(cat $repo/some-file)" = 1.2.3
}

it_can_check_with_version() {
  check_key_from "some-version" "1.0.0" | jq -e "
    .[0] == {number: $(echo 1.0.0 | jq -R .)}
  "
}

run it_can_check_with_no_current_version
run it_can_check_with_version
