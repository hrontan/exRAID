#!/bin/sh


##Initilaize exRAID##

##20,30,40GB Drives are added.
##Make 50GB RAID5 like file system.

#install packages
sudo apt-get update
sudo apt-get install lvm2 mdadm parted

#label gpt & make partitions
#10,000,000,000/512 = 19531250s 
#19531776s (which are more then 19531250s and can bew divided by 2048) 
sudo parted -s /dev/sdb mklabel gpt
sudo parted -s /dev/sdb mkpart md0 2048s 19533823s
sudo parted -s /dev/sdb mkpart md1 19533824s 39065599s
sudo parted -s /dev/sdc mklabel gpt
sudo parted -s /dev/sdc mkpart md0 2048s 19533823s
sudo parted -s /dev/sdc mkpart md1 19533824s 39065599s
sudo parted -s /dev/sdc mkpart md2 39065600s 58597375s
sudo parted -s /dev/sdd mklabel gpt
sudo parted -s /dev/sdd mkpart md0 2048s 19533823s
sudo parted -s /dev/sdd mkpart md1 19533824s 39065599s
sudo parted -s /dev/sdd mkpart md2 39065600s 58597375s
sudo parted -s /dev/sdd mkpart md3 58597376s 78129151s


#create array
sudo mdadm --create --assume-clean /dev/md0 --level=5 --raid-devices=3 /dev/sdb1 /dev/sdc1 /dev/sdd1
sudo mdadm --create --assume-clean /dev/md1 --level=5 --raid-devices=3 /dev/sdb2 /dev/sdc2 /dev/sdd2
sudo mdadm --create --assume-clean /dev/md2 --level=1 --raid-devices=2 /dev/sdc3 /dev/sdd3
sudo mdadm --detail --scan > /etc/mdadm.conf

#set lvm2
sudo pvcreate -M2 /dev/md0 
sudo pvcreate -M2 /dev/md1
sudo pvcreate -M2 /dev/md2
sudo vgcreate storage /dev/md0 /dev/md1 /dev/md2
sudo lvcreate -l 100%FREE storage

#format to ext4
sudo mkfs -t ext4 -T largefile /dev/storage/lvol0

##Extend exRAID##
##50GB Drive is added to make 90GB Drive.

sudo parted -s /dev/sde mklabel gpt
sudo parted -s /dev/sde mkpart md0 2048s 19533823s
sudo parted -s /dev/sde mkpart md1 19533824s 39065599s
sudo parted -s /dev/sde mkpart md2 39065600s 58597375s
sudo parted -s /dev/sde mkpart md3 58597376s 78129151s
sudo parted -s /dev/sde mkpart md4 78129152s 97660927s

sudo mdadm --add /dev/md0 /dev/sde1
sudo mdadm --add /dev/md1 /dev/sde2
sudo mdadm --add /dev/md2 /dev/sde3
sudo mdadm --create --assume-clean /dev/md3 --level=1 --raid-devices=2 /dev/sdd4 /dev/sde4
sudo mdadm --grow --level=5 --raid-devices=4 /dev/md0
sudo mdadm --grow --level=5 --raid-devices=4 /dev/md1
sudo mdadm --grow --level=5 --raid-devices=3 /dev/md2
sudo mdadm --detail --scan > /etc/mdadm.conf

sudo pvcreate -M2 /dev/md3
sudo vgextend storage /dev/md3
sudo pvresize /dev/md0
sudo pvresize /dev/md1
sudo pvresize /dev/md2
sudo lvextend -l +100%FREE /dev/storage/lvol0 

sudo resize2fs /dev/storage/lvol0


##Rebuild Broken Drive##
##20GB Drive id Broken and Replace it with 60GB Drive##

sudo parted -s /dev/sdb mklabel gpt
sudo parted -s /dev/sdb mkpart md0 2048s 19533823s
sudo parted -s /dev/sdb mkpart md1 19533824s 39065599s
sudo parted -s /dev/sdb mkpart md2 39065600s 58597375s
sudo parted -s /dev/sdb mkpart md3 58597376s 78129151s
sudo parted -s /dev/sdb mkpart md4 78129152s 97660927s

sudo mdadm --add /dev/md0 /dev/sdb1
sudo mdadm --add /dev/md1 /dev/sdb2
sudo mdadm --add /dev/md2 /dev/sdb3
sudo mdadm --add /dev/md3 /dev/sdb4
sudo mdadm --add /dev/md4 /dev/sdb5
sudo mdadm --create --assume-clean /dev/md5 --level=1 --raid-devices=2 /dev/sdb5 /dev/sde5
sudo mdadm --grow --level=5 --raid-devices=4 /dev/md2
sudo mdadm --grow --level=5 --raid-devices=3 /dev/md3
sudo mdadm --detail --scan > /etc/mdadm.conf

sudo pvcreate -M2 /dev/md5
sudo vgextend storage /dev/md5
sudo pvresize /dev/md0
sudo pvresize /dev/md1
sudo pvresize /dev/md2
sudo pvresize /dev/md3
sudo pvresize /dev/md4
sudo lvextend -l +100%FREE /dev/storage/lvol0 

sudo e2fsck -f /dev/storage/lvol0
sudo resize2fs /dev/storage/lvol0

##Add Spare Drive##
##Add 60 GB Drive as Spare Disk##
sudo parted -s /dev/sdb mklabel gpt
sudo parted -s /dev/sdb mkpart md0 2048s 19533823s
sudo parted -s /dev/sdb mkpart md1 19533824s 39065599s
sudo parted -s /dev/sdb mkpart md2 39065600s 58597375s
sudo parted -s /dev/sdb mkpart md3 58597376s 78129151s
sudo parted -s /dev/sdb mkpart md4 78129152s 97660927s

sudo mdadm --add /dev/md0 /dev/sdb1
sudo mdadm --add /dev/md1 /dev/sdb2
sudo mdadm --add /dev/md2 /dev/sdb3
sudo mdadm --add /dev/md3 /dev/sdb4
sudo mdadm --add /dev/md4 /dev/sdb5
sudo mdadm --detail --scan > /etc/mdadm.conf



