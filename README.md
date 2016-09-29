# Epochal Version Resource

If SEMVER isn't exactly your thing, you might like Epochal Versioning.

## x.y.z

* `x` days since epoch
* `y` builds that day
* `z` hotfix

## Installing

```
resource_types:
- name: epochver
  type: docker-image
  source:
    repository: jcderr/concourse-epochver-resource
resources:
- name: version
  type: epochver
  source:
    aws_access_key_id: ...
    aws_secret_access_key: ...
    bucket: ...
    key: ...
    region: us-east-1
    epoch: date
```

## Source Configuration

* `bucket`: *Required.* S3 Bucket Name.
* `key`: *Required.* S3 Key Name.
* `aws_access_key_id`: *Required.* AWS SDK Access Key ID.
* `aws_secret_access_key`: *Required.* AWS SDK Secret Access Key.
* `region`: *Optional.* AWS Region. (default: us-east-1)
* `epoch`: *Required.* Date (YYYY-MM-DD) of the Epoch.

#### `check`: Report the current build version

Detects new versions by reading the file from the specified source. If the
file is empty, it returns the first build (X.0.0) for the number of days since
the `epoch` date. If the file is not empty, it returns the version specified in
the file if it is equal to or greater than current version, otherwise it
returns no versions.

#### `in`: Gets Most Recent Build Version

Provide the version as a file, optionally bumping it.

Provides the version number to the build as a number file in the destination.

Can be configured to bump the version locally, which can be useful for getting
the final version ahead of time when building artifacts.

The destination directory will have two files: the latest version (with
optional bump) in `destination/version` and the full version history in
`destination/history.json`. 

##### Parameters

* `bump`: *Optional.* Bumps `build` number (y) or `hotfix` (z).

#### `out`: Set the version or bump the current one.

Given a file, use its contents to update the version. Or, given a bump strategy,
bump whatever the current version is. If there is no current version, the bump
will be based on initial_version.

The file parameter should be used if you have a particular version that you
want to force the current version to be. This can be used in combination with
in, but it's probably better to use the bump and pre params as they'll perform
an atomic in-place bump if possible with the driver.

#### Parameters

* `file`: *Optional.* Path to a file containing the version number to set.
* `bump`: *Optional.* Bump `build` number (y) or `hotfix` (z).

## Example

### Out
```
resource_types:
- name: epochver
  type: docker-image
  source:
    repository: jcderr/concourse-epochver-resource
resources:
- name: version
  type: epochver
  source:
    aws_access_key_id: ...
    aws_secret_access_key: ...
    region: us-east-1
    bucket: my-version-bucket
    key: some-project/version
```

```
---
- put: version
  params:
    file: project/version
```

Or

```
---
- put: version
  params:
    bump: build
```
