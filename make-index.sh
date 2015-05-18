#!/bin/bash
#
# Verify package signatures and generate index.
#
# VERSION       :0.2
# DATE          :2015-05-18
# AUTHOR        :Viktor Szépe <viktor@szepe.net>
# LICENSE       :The MIT License (MIT)
# URL           :https://github.com/szepeviktor/debian-server-tools
# BASH-VERSION  :4.2+
# DEPENDS       :apt-get install dpkg-sig
# DEPENDS       :https://github.com/szepeviktor/debian-server-tools/blob/master/package/index_gen.py

# my GPG key
echo "dpkg-sig -k 451A4FBA --sign builder *.deb"
echo "cd debian/"
echo "REMOVE:  reprepro remove jessie <PKG>"
echo "reprepro includedeb jessie /var/cache/pbuilder/result/*.deb"

which dpkg-sig index_gen.py &> /dev/null || exit 99

pushd debian/

# Verify all packages
DEBS="$(find -type f -name "*.deb")"
while read PKG; do
    echo -n "${PKG} ... "
    dpkg-sig --verify "$PKG" | grep "^GOODSIG" || exit 1
done <<< "$DEBS"

# Generate index
index_gen.py > index.html
sed -i 's|<body>|<head><title>Modern webserver solutions</title></head><body><h1>Modern webserver solutions</h1><h2>Debian Linux packages backported from jessie</h2>|' \
    index.html

popd

echo "Index generated."

git status

echo
echo "git add --all"
