#!/usr/bin/env python2.7
from __future__ import print_function
from __future__ import unicode_literals

from base64 import b64encode
from json import dump
from os import getenv
from os.path import expanduser
from os.path import dirname
from os.path import join
from sys import argv
from sys import stderr

FILE_DIRECTORY = expanduser(getenv('K8S_CERTIFICATES', '/etc/kubernetes/pki/'))
FILES_TO_ADD = ('apiserver.crt', 'apiserver.key', 'ca.crt')

def _base_secret_structure(namespace, secret_name):
	return {
		'apiVersion': 'v1',
		'kind': 'Secret',
		'metadata': {
		  'name': secret_name,
		  'namespace': namespace,
		},
		'data': {},
	}

def main():
	if len(argv) != 3:
		print('Usage: {} <namespace> <secret name>'.format(argv[0]), file=stderr)
		exit(1)

	secret = _base_secret_structure(argv[1], argv[2])
	for file_to_encode in FILES_TO_ADD:
		file_path = join(FILE_DIRECTORY, file_to_encode)
		with open(file_path) as f:
			file_content = ''.join(f.readlines())
			secret['data'][file_to_encode] = b64encode(file_content)

	with open('{}.json'.format(join(dirname(__file__), argv[2])), 'w') as f:
		dump(secret, f, indent=2)

if __name__ == '__main__':
	exit(main())
