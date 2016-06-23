#!/bin/bash
#
# Verify package signatures and generate index.
#
# VERSION       :0.2.2
# DATE          :2015-05-18
# AUTHOR        :Viktor Szépe <viktor@szepe.net>
# LICENSE       :The MIT License (MIT)
# URL           :https://github.com/szepeviktor/debian-server-tools
# BASH-VERSION  :4.2+
# DEPENDS       :apt-get install dpkg-sig
# DEPENDS       :/usr/local/bin/index_gen.py

cat <<EOF
# My GPG key
dpkg-sig -k 451A4FBA --sign builder /opt/results/*.deb
cd debian/
# REMOVE:  reprepro remove jessie <PKG>
reprepro includedeb jessie /opt/results/*.deb
EOF

which index_gen.py &> /dev/null || exit 99

pushd debian/ || exit 1

# Verify all packages
DEBS="$(find -type f -mtime -30 -name "*.deb")"
while read PKG; do
    echo -n "${PKG} ... "
    dpkg-sig --verify "$PKG" | grep --color "^GOODSIG" || exit 2
done <<< "$DEBS"

# Generate index
index_gen.py > index.html
sed -i -e 's|<body>|<head><title>Modern webserver solutions</title></head><body><h1>Modern webserver solutions</h1><h2>Freshly packaged and backported Debian Linux packages</h2>|' \
    index.html

popd

echo "Index generated."

git status -s

echo
echo "git add --all"
