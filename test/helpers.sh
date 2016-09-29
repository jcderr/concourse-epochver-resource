#!/bin/sh

set -e -u

set -o pipefail

resource_dir=/opt/resource

run() {
  export TMPDIR=$(mktemp -d /tmp/epochal-tests.XXXXXX)

  echo -e 'running \e[33m'"$@"$'\e[0m...'
  eval "$@" 2>&1 | sed -e 's/^/  /g'
  echo ""
}

check_key_from() {
  jq -n "{
    source: {
      driver: \"s3\",
      access_key_id: \"$AWS_ACCESS_KEY_ID\",
      secret_access_key: \"$AWS_SECRET_ACCESS_KEY\",
      bucket: \"concourse-resource-testing\",
      key: \"test/$1\"
    },
    version: {
      number: $(echo $2 | jq -R .)
    }
  }" | ${resource_dir}/check "$3" | tee /dev/stderr
}

put_key() {
  jq -n "{
    source: {
      driver: \"s3\",
      access_key_id: \"$AWS_ACCESS_KEY_ID\",
      secret_access_key: \"$AWS_SECRET_ACCESS_KEY\",
      bucket: \"bypass-concourse-testing\",
      key: \"test/$1\"
    },
    params: {
      key: $(echo $3 | jq -R .)
    }
  }" | ${resource_dir}/out "$2" | tee /dev/stderr
}

put_key_with_bump() {
  jq -n "{
    source: {
      driver: \"s3\",
      access_key_id: \"$AWS_ACCESS_KEY_ID\",
      secret_access_key: \"$AWS_SECRET_ACCESS_KEY\",
      bucket: \"bypass-concourse-testing\",
      key: \"test/version\"
    },
    params: {
      bump: $(echo $3 | jq -R .)
    }
  }" | ${resource_dir}/out "$2" | tee /dev/stderr
}

put_s3_with_bump_and_initial() {
  jq -n "{
    source: {
      driver: \"s3\",
      access_key_id: \"$AWS_ACCESS_KEY_ID\",
      secret_access_key: \"$AWS_SECRET_ACCESS_KEY\",
      bucket: \"bypass-concourse-testing\",
      key: \"test/version\"
    },
    params: {
      bump: $(echo $4 | jq -R .),
    }
  }" | ${resource_dir}/out "$2" | tee /dev/stderr
}
