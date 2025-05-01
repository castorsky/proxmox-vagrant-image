#!/bin/sh

# List installed PVE kernels (except the running one) and remove them
dpkg --list | grep -E "pve-kernel\S+-pve" | awk '{ print $2 }' | sort -V | sed -n '/'`uname -r`'/q;p' | xargs sudo apt-get -y purge
# Clear APT cache in the most barbarian manner
rm -rf /var/cache/apt
# Trim filesystem with system utility
fstrim -v /
# Trim filesystem with dirty hack
dd if=/dev/zero of=/zeroed bs=1M
sync; sleep 1
rm -f /zeroed
