#!/bin/bash
#
# Verify package signatures and generate index.
#
# VERSION       :0.2.3
# DATE          :2015-05-18
# AUTHOR        :Viktor Szépe <viktor@szepe.net>
# LICENSE       :The MIT License (MIT)
# URL           :https://github.com/szepeviktor/debian-server-tools
# BASH-VERSION  :4.2+
# DEPENDS       :apt-get install dpkg-sig reprepro
# DEPENDS       :/usr/local/bin/index_gen.py

set -e

# Before this script
cat <<"EOF"
# Sign it with my GPG key
dpkg-sig --sign "builder" -k "451A4FBA" /opt/results/*.deb
cd debian/
# REMOVE:  reprepro remove jessie <PKG>
reprepro includedeb jessie /opt/results/*.deb
EOF

(
    cd debian/

    # Verify packages updated in the last month
    DEBS="$(find -type f -mtime -30 -name "*.deb")"
    while read -r PKG; do
        echo -n "${PKG} ... "
        dpkg-sig --verify "$PKG" | grep --color "^GOODSIG"
    done <<< "$DEBS"

    # Generate index
    index_gen.py > index.html
    sed -i -e 's|<body>|<head><title>Modern webserver solutions</title></head><body><h1>Modern webserver solutions</h1><h2>Freshly packaged and backported Debian Linux packages</h2>|' \
        index.html
    echo "Index generated."
)

git status -s

# After this script
cat <<"EOF"

git add --all
git commit
git push
EOF
