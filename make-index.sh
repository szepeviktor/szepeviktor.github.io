#!/bin/bash
#
# Verify package signatures and generate index.
#
# VERSION       :0.3.0
# DATE          :2017-10-15
# AUTHOR        :Viktor Szépe <viktor@szepe.net>
# LICENSE       :The MIT License (MIT)
# URL           :https://github.com/szepeviktor/debian-server-tools
# BASH-VERSION  :4.2+
# DEPENDS       :apt-get install dpkg-sig reprepro
# DEPENDS       :/usr/local/bin/index_gen.py

set -e

# Before this script
cat <<"EOF"
# Sign it with the packaging GPG key
GPG_TTY="$(tty)" dpkg-sig --sign "builder" -k "451A4FBA" /opt/results/*.deb
cd debian/
# REMOVE:  reprepro remove stretch PACKAGE
reprepro includedeb stretch /opt/results/*.deb
EOF

(
    cd debian/

    # Verify packages updated in the last month
    DEBS="$(find . -type f -mtime -30 -name "*.deb")"
    while read -r PKG; do
        echo -n "${PKG} ... "
        dpkg-sig --verify "$PKG" | grep --color "^GOODSIG"
    done <<<"$DEBS"

    # Generate index
    ../../package/index_gen.py >index.html
    sed -e 's|<body>|<head><title>Modern webserver solutions</title></head><body><h1>Modern webserver solutions</h1><h2>Freshly packaged and backported Debian Linux packages</h2>|' \
        -i index.html
    echo "Index generated."
)

git status -s

# Commit to git and parent repo
cat <<"EOF"

git add --all; git commit
git push
cd ../; git add repo
EOF
