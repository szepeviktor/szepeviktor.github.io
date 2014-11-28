#!/bin/bash

# my GPG key
echo "dpkg-sig -k 451A4FBA --sign builder *.deb"
echo "cd debian/"
echo "REMOVE:  reprepro remove wheezy <PKG>"
echo "reprepro includedeb wheezy *.deb"


which index_gen.py &> /dev/null || exit 1

pushd debian/

index_gen.py > index.html
sed -i 's|<body>|<head><title>Modern webserver solutions</title></head><body><h1>Modern webserver solutions</h1><h2>Debian Linux packages backported from jessie</h2>|' \
    index.html

popd
