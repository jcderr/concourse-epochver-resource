import sys, os
import json
import datetime

from boto.s3.connection import S3Connection
from boto.exception import S3ResponseError

class EpochHistory(object):
    history = []
    s3_bucket = None
    s3_key = None
    epoch = None

    def __init__(self, **kwargs):
        if 's3bucket' in kwargs:
            self.s3_bucket = kwargs['s3bucket']
        if 's3key' in kwargs:
            self.s3_key = kwargs['s3key']

        if 'epoch' in kwargs:
            _epoch_date = kwargs['epoch']
        else:
            _epoch_date = '2016-01-01'

        self.epoch = datetime.datetime.strptime(
            _epoch_date, "%Y-%m-%d").date()

        self.get_from_s3()

    def get_from_s3(self):
        conn = S3Connection()
        bucket = conn.get_bucket(self.s3_bucket)

        try:
            key = bucket.get_key(self.s3_key)
            key_value = key.get_contents_as_string().decode(
                'utf-8').rstrip('\n')
        except Exception, e:
            key_value = "{\"versions\": [\"0.0.0\"]}"

        data = json.loads(key_value)
        for version in data['versions']:
            self.history.append(version)

    def commit(self):
        conn = S3Connection()
        bucket = conn.get_bucket(self.s3_bucket)
        key = bucket.get_key(self.s3_key)
        key.set_contents_from_string(self.json)

    def sort(self):
        self.history.sort(key=lambda s: list(map(int, s.split('.'))),
            reverse=True)

    def add_version(self, version):
        self.history.append(version)
        self.sort()

    def patch_version(self, version):
        if not version in self.history:
            return False
        else:
            _major, _minor, _patch = version.split('.')
            _major = int(_major)
            _minor = int(_minor)
            _patch = int(_patch)

            _patch += 1

            while '{}.{}.{}'.format(_major, _minor, _patch) in self.history:
                _patch += 1

        return "{}.{}.{}".format(_major, _minor, _patch)

    @property
    def json(self):
        return json.dumps({"versions": self.history})

    @property
    def days_since_epoch(self):
        _delta = datetime.date.today() - self.epoch
        return _delta.days

    @property
    def next_version(self):
        _major, _minor, _patch = self.history[0].split('.')
        _major = int(_major)
        _minor = int(_minor)
        _patch = int(_patch)

        if _major == self.days_since_epoch:
            _minor += 1
            _patch = 0
        else:
            _major = self.days_since_epoch
            _minor = 0
            _patch = 0

        return "{}.{}.{}".format(_major, _minor, _patch)



class EpochVersion(object):
    major = 0
    minor = 0
    patch = 0

    def __init__(self, **kwargs):
        if 'version' in kwargs:
            self.major, self.minor, self.patch = kwargs['version'].split('.')
        elif all(k in kwargs for k in ("major", "minor", "patch")):
            self.major = kwargs["major"]
            self.minor = kwargs["minor"]
            self.patch = kwargs["patch"]
