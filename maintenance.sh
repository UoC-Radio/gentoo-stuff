echo "Verifying package integrity..."

PACKAGE_LIST=`equery list "*"`

for i in $PACKAGE_LIST; do
	equery check $i
done

echo "Cleaning up core dumps saved by systemd..."
rm /var/lib/systemd/coredump/core.*

echo "Cleaning up dhcp leases..."
rm /var/lib/NetworkManager/*.lease
rm /var/lib/NetworkManager/*.lease6
rm /var/lib/dhcpcd/*.lease
rm /var/lib/dhcpcd/*.lease6

echo "Getting list of tracked files..."

cat /var/db/pkg/*/*/CONTENTS | sed -r 's/^... //; s/ ([0-9a-f]+ )[0-9]+$//; s/ -> .*$//' | sort -u > /tmp/tracked_files

echo "Getting list of files on app etc folders..."

find / \( -path /dev -o -path /proc -o -path /sys -o -path /media \
          -o -path /mnt -o -path /run -o -path /var/run \
	  -o -path /tmp -o -path /var/tmp -o -path /usr/tmp \
	  -o -path /home -o -path /root -o -path /boot \
	  -o -path /lib/modules -o -path /lib64/modules \
	  -o -path /var/db/pkg -o -path /var/lib/layman \
	  -o -path /var/lib/portage -o -path /var/lib/gentoo \
	  -o -path /usr/lib64/portage -o -path /var/lib64/gentoo \
	  -o -path /usr/portage -o -path /etc/portage \
	  -o -path /usr/share/mime -o -path /usr/src \
	  -o -path /etc/NetworkManager/system-connections \
	  -o -path /etc/ssh -o -path /etc/X11 -o -path /etc/conf.d \
	  -o -path /var/log -o -path /var/cache \) -prune \
	  -o -type f | sort -u > /tmp/all_files

echo "Generating list of orphans..."

comm -23 /tmp/all_files /tmp/tracked_files > /tmp/orphans

rm /tmp/all_files /tmp/tracked_files

echo "List of orphans on /tmp/orphans"

echo "Generating list of orphans older than 6 months..."
for i in `cat /tmp/orphans`; do
	if [ -f "${i}" ]; then
		find "${i}" -mtime +180 >> /tmp/old-orphans
	fi
done

echo "List of old orphans on /tmp/old-orphans"
