### Notify on ssh login/logout via gotify

#### Setup
1) Copy script [ssh-notfiy.sh](./scripts/ssh-notify.sh) to `/etc/ssh/login-notify.sh`
2) Make script exectuable: `chmod +x /etc/ssh/login-notify.s`
3) Edit `/etc/pam.d/sshd`, add: `session required pam_exec.so seteuid /etc/ssh/login-notify.sh`

#### Links/related information:
- https://askubuntu.com/a/448602/1034948

---


### MDADM notifications via gotify

#### Setup
1) Copy script [raid-realthcheck.sh](./scripts/raid-realthcheck.sh) to `/root/raid-realthcheck.sh`
2) Make script executable: `chmod +x /root/raid-realthcheck.sh`
3) Add to `mdadm.conf` (On Rocky `/etc/mdadm.conf`): `PROGRAM /root/raid-healthcheck.sh`

#### Links/related information:
- https://github.com/hunleyd/mdadm_notify
- https://www.suse.com/de-de/support/kb/doc/?id=000016716

----

### Grow root parition (Rocky 9)

#### Extend partition to remaining size
1) install `dnf install -y cloud-utils-growpart`
2) `growpart  /dev/vda 2`
3) `pvs` & `vgs` & `lvs`
4) `lvextend -l +100%FREE /dev/rl_nextcloud/root`
5) `xfs_growfs /`

----

### Resize disks
```sh
#!/bin/bash
for i in `echo "sda sdb sdc sdd sde sdf sdg sdh"`; do
  echo 1 > /sys/block/$i/device/rescan
done

for i in `echo "sdb sdc sdd sde sdf sdh sdg"`; do
  echo "Fix" | parted ---pretend-input-tty /dev/$i print
  parted -s /dev/$i resizepart 1 '100%' &&
  pvresize /dev/"$i"1
done

for x in `ls /dev/mapper/vg_hana*`; do
  lvextend -l+100%FREE $x &&
  xfs_growfs $x
done
```
