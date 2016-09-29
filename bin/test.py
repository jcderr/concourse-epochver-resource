#!/usr/bin/env python

import sys

from epochver.epoch import EpochHistory

history = EpochHistory(s3bucket="concourse-resource-testing",
        s3key="test/some-version")

history.sort()

print('S3 Fetch: ' + history.json)

history.add_version(history.next_version)
history.commit()
print('New history: ' + history.json)

history.add_version(history.patch_version(version="272.0.0"))
history.commit()
print('New history: ' + history.json)
