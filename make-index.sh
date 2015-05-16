#!/bin/bash

# my GPG key
echo "dpkg-sig -k 451A4FBA --sign builder *.deb"
echo "cd debian/"
echo "REMOVE:  reprepro remove jessie <PKG>"
echo "reprepro includedeb jessie *.deb"


# apt-get install dpkg-sig
# index_gen.py: https://github.com/szepeviktor/debian-server-tools/tree/master/package
which dpkg-sig index_gen.py &> /dev/null || exit 99

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

git status
echo
echo "git add --all"
