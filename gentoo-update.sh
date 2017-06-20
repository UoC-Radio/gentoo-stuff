#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Updating sources..."
# We do webrsync to verify the signature of the
# whole tree using gentoo-keys (gpg)
emerge-webrsync -q
layman -S -q
eix-update -q

echo "Updating system..."
# Note: Some packages compile helper tools as part of their build
# process and these tools are not marked by portage for PaX. Make
# sure that we don't break packages because of that by disabling
# PaX protections (softmode) durring upgrade.
# Note2: I removed tpe from my kernel config since I didn't like
# it much and was buggy.
#sysctl kernel.grsecurity.tpe=0 &> /dev/null
#sysctl kernel.pax.softmode=1 &> /dev/null
emerge -uDN @world --with-bdeps=y --backtrack=30 --keep-going --quiet --autounmask-write
emerge @preserved-rebuild --quiet
#sysctl kernel.pax.softmode=0 &> /dev/null
#sysctl kernel.grsecurity.tpe=1 &> /dev/null

echo "Cleaning up..."
emerge --depclean --quiet
perl-cleaner --all -q
python-updater
revdep-rebuild -q
etc-update
eclean -d distfiles

# Now fix file capability bits
${DIR}/fixcaps.sh

# Do a ccache cleanup
CCACHE_DIR="/var/tmp/ccache" ccache -c

# Finaly update the symlink for the lto plugin, in case
# we updated gcc
GCC_VERSION=`gcc -dumpversion`

ln -s /usr/libexec/gcc/x86_64-pc-linux-gnu/${GCC_VERSION}/liblto_plugin.so.0.0.0 /usr/x86_64-pc-linux-gnu/binutils-bin/lib/bfd-plugins/
