#!/bin/bash
set -e
fixed_size=$1 # 2048G/2047G
echo "Please enter the Disks You Will Use for Volume Creation, Once At A Time(eg. /dev/sdb)"
declare -a disks
i=0
while true
do
    echo "----------------------------------------------"
    fdisk -l | grep "Disk /dev/" | grep -v loop | grep -v mapper
    echo "----------------------------------------------"
	echo "Please Enter The Disk "$i": "
    read disk
    
    for control in "${disks[@]}"
    do
        if [[ $control == $disk ]];then
            echo "There are duplicate entries for this disk:"$disk
            echo "Please restart the script and input one entry for each disk."
            exit 1
        fi
    done

    disks+=($disk)
    disk_control=$( fdisk -l | grep "Disk "$disk)
    if [[ $disk_control == "" ]];then
        echo "Program is exiting.There is no such a disk :"$disk
        echo "Please restart the script and correct entries."
        exit 1
    fi

    echo "Continue to add disk?(y:n)"
    read answer

    if [[ $answer == "n" ]];then
    break
    fi
	let "i=i+1"
done

for disk in "${disks[@]}"
do
    echo "---------"
    echo $disk
    echo "---------"
done

echo "Below disks are merge into one logival volume.Are you sure ?(y:n)"
read answer
if [[ $answer != "y" ]];then
echo "Cancelling.."
exit 1
fi

sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk ${disks[0]}
  n
  p
  1


  t
  8e
  w
EOF

apt-get install lvm2 -y
modprobe dm-mod
echo "dm-mod">> /etc/modules
vgscan
disk_name=${disks[0]}"1"
pvcreate $disk_name
vgcreate vdisk $disk_name
lvcreate -l100%FREE -nvolume vdisk
mke2fs -t ext4 /dev/vdisk/volume
mkdir /mnt/storage
mount /dev/vdisk/volume /mnt/storage
echo "/dev/vdisk/volume /mnt/storage ext4 defaults 0 1" >> /etc/fstab


control=0
for disk in "${disks[@]}"
do
if [[ $control -eq 0 ]];then
    control=1
    continue
fi
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk $disk
  n
  p
  1


  t
  8e
  w
EOF

disk_name=$disk"1"
vgextend vdisk $disk_name
umount /dev/vdisk/volume

if [[ $fixed_size == "" ]];then
size=$(fdisk -l | grep $disk_name | awk '{print $5}' |  sed 's/[A-Za-z]*//g')
letter=$(fdisk -l | grep $disk_name | awk '{print $5}' |  sed 's/[A-Za-z]*//g')
let "size=size-1"
lvextend -L+"$size"G /dev/vdisk/volume
else
lvextend -L+$fixed_size /dev/vdisk/volume
fi

e2fsck -f /dev/vdisk/volume
resize2fs -f /dev/vdisk/volume
mount /dev/vdisk/volume /mnt/storage

done

fdisk -l
echo "Done."
