#!/usr/bin/env python
import argparse
import plistlib
import json
import os
import sys

valid_bumps = ['major', 'minor', 'bugfix']

#
# Argparse
#
parser = argparse.ArgumentParser(description='Bump version in xcode project and podspec')
parser.add_argument('bump', type=str, nargs='?', default=valid_bumps[2], choices=valid_bumps, help='Which part of semantic verison to bump default: bugfix')
parser.add_argument('--version', dest='version', help='explicitly set a version, ignores semver specified')
parser.add_argument('--tag', action='store_true', help='tag the git repository with new version')
# parser.add_argument('--no-build', action='store_true', help='doesn\'t increment the build number')
parser.add_argument('-p', metavar='plist', help='plist file to operate on')
parser.add_argument('-s', metavar='podspec',  help='podspec file to operate on')
args = parser.parse_args()


def error(msg):
    print("=== Error ===\n%s\n=============\n" % msg)
    parser.print_help()
    sys.exit(-1)

project_name = None

podspec = args.s
plist = args.p

if (plist is None) or (podspec is None):
    for element in os.listdir('.'):
        if 'xcodeproj' in element:
            project_name = element.split('.')[0]
            break

    if project_name is None:
        error('Your not in a Xcode project directory, cannot find xcodeproj\nPlease specify Info.plist and podspec.json to operate on')

    if plist is None:
        plist = "%s/%s-Info.plist" % (project_name, project_name)

    if podspec is None:
        podspec = "%s.podspec.json" % project_name

# check files
if not os.path.isfile(plist):
    error('plist: %s file not found' % plist)

if not os.path.isfile(podspec):
    error('podspec: %s file not found' % podspec)

# read plist
plist_d = plistlib.readPlist(plist)


# read podspec
f = open(podspec, 'r')
podspec_d = json.load(f)
f.close()

current_version = plist_d['CFBundleShortVersionString']
new_version = current_version

print('Current Version is %s' % current_version)

if args.version is None:
    version_split = current_version.split('.')

    if args.bump == 'bugfix':
        version_split[2] = str(int(version_split[2]) + 1)
    elif args.bump == 'minor':
        version_split[1] = str(int(version_split[1]) + 1)
        version_split[2] = '0'
    elif args.bump == 'major':
        version_split[0] = str(int(version_split[0]) + 1)
        version_split[1] = '0'
        version_split[2] = '0'

    print(version_split)
    new_version = '.'.join(version_split)
else:
    new_version = args.version

print('New Version will be %s' % new_version)

# edit objects
podspec_d['version'] = new_version
podspec_d['source']['tag'] = new_version

plist_d['CFBundleShortVersionString'] = new_version

# Saving files
print("Saving files...")

try:
    with open(podspec, 'w') as fp:
        json.dump(podspec_d, fp, sort_keys=False, indent=4, separators=(',', ': '))
        plistlib.writePlist(plist_d, plist)
except Exception, e:
    error(e.message)

print('OK')
