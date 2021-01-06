#!/bin/bash
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk $DISK
1
d
d
2
n
p
1


No
a
w
EOF

resize2fs /dev/sda1
reboot
#You may wait a bit longer after reboot.
