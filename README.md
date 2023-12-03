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