#!/bin/bash

echo "Restoring file capability bits..."

# arping (from chromium's baseline.fscap -only on root's path, no suid bit set by default) - submited
#setcap cap_net_raw+ep /usr/sbin/arping

# ecryptfs-utils (OK -submited)
# Note: setuid/gid for setting them to 0/0, sys_admin for mount() and dac_read_search because
# by default the private directory is only readable by the user (so when it runs with uid 0
# even though that's root's uid it doesn't have root's capabilities).
setcap cap_dac_read_search,cap_setgid,cap_setuid,cap_sys_admin+ep /sbin/mount.ecryptfs_private

# fusermount (OK -submited)
setcap cap_sys_admin+ep /usr/bin/fusermount

# netselect (OK -submited)
setcap cap_net_raw+ep /usr/bin/netselect

# open-vm-tools
# small suid wrapper for operating on vmblock (which I think it's obsolete). Is this still needed ?
#/usr/bin/vmware-user-suid-wrapper = ?

# polkit
#/usr/bin/pkexec = ?
#/usr/lib/polkit-1/polkit-agent-helper-1 = ?

# ppp (?)
# suid root and can be executed by others !
# Note: requres cap_net_admin to modify rooting table (only ?)
# TODO Test this
setcap cap_net_admin+ep /usr/sbin/pppd

# shadow (OK -submited)
# -l option allows for a user to see his/her account's password expiry date
setcap cap_dac_read_search+ep /usr/bin/chage
# changes the user's information (full name, phone number etc) on /etc/passwd
setcap cap_chown,cap_setuid+ep /usr/bin/chfn
# changes the user's login shell on /etc/passwd
setcap cap_chown,cap_setuid+ep /usr/bin/chsh
# checks if the user's password has expired and forces a password change in case it has
setcap cap_dac_override,cap_setgid+ep /usr/bin/expiry
# allows root and group administrators to set/change group passwords on /etc/gshadow
setcap cap_chown,cap_dac_override,cap_setuid+ep /usr/bin/gpasswd
# alows users to set their current group ID in case they know the group's password or are members of the group
setcap cap_dac_override,cap_setgid+ep /usr/bin/newgrp
# allows users to change their password on /etc/shadow
setcap cap_chown,cap_dac_override,cap_fowner+ep /bin/passwd
# writes uid mappings on /proc/<pid>/uid_map
setcap cap_setuid+ep /usr/bin/newuidmap
# writes gid mappings on /proc/<pid>/guid_map
setcap cap_setgid+ep /usr/bin/newgidmap
