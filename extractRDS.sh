#!/bin/bash

mkdir ~/nsrl/ && cd ~/nsrl
wget http://www.nsrl.nist.gov/RDS/rds_2.41/RDS_241_A.iso
wget http://www.nsrl.nist.gov/RDS/rds_2.41/RDS_241_B.iso
wget http://www.nsrl.nist.gov/RDS/rds_2.41/RDS_241_C.iso
wget http://www.nsrl.nist.gov/RDS/rds_2.41/RDS_241_D.iso
sudo mkdir -p /mnt/isoA
sudo mount -o loop ~/nsrl/RDS_241_A.iso /mnt/isoA
cd /tmp/
unzip -o /mnt/isoD/rds_241_c.zip
mv NSRL*.txt ~/nsrl/
sudo mkdir -p /mnt/isoB
sudo mount -o loop ~/nsrl/RDS_241_B.iso /mnt/isoB
unzip -o /mnt/isoB/rds_241_b.zip
sed '1d' /tmp/NSRLFile.txt >> ~/nsrl/NSRLFile.txt
sudo mkdir -p /mnt/isoC
sudo mount -o loop ~/nsrl/RDS_241_C.iso /mnt/isoC
cd /tmp/
unzip -o /mnt/isoC/rds_241_c.zip
sed '1d' /tmp/NSRLFile.txt >> ~/nsrl/NSRLFile.txt
sudo mkdir -p /mnt/isoD
sudo mount -o loop ~/nsrl/RDS_241_D.iso /mnt/isoD
cd /tmp/
unzip -o /mnt/isoD/rds_241_d.zip
sed '1d' /tmp/NSRLFile.txt >> ~/nsrl/NSRLFile.txt