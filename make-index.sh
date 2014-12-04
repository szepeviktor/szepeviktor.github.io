#!/bin/bash

# my GPG key
echo "dpkg-sig -k 451A4FBA --sign builder *.deb"
echo "cd debian/"
echo "REMOVE:  reprepro remove wheezy <PKG>"
echo "reprepro includedeb wheezy *.deb"


which index_gen.py &> /dev/null || exit 99

pushd debian/

# verify all packages
find -type f -name "*.deb" \
    | while read PKG; do
        dpkg-sig --verify "$PKG" || exit 1
    done

index_gen.py > index.html
sed -i 's|<body>|<head><title>Modern webserver solutions</title></head><body><h1>Modern webserver solutions</h1><h2>Debian Linux packages backported from jessie</h2>|' \
    index.html

popd

echo "Index generated."
