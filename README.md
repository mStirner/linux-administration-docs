### Notify on ssh login/logout via gotify

#### Setup
1) Copy script [ssh-notfiy.sh](./scripts/ssh-notify.sh) to `/etc/ssh/login-notify.sh`
2) Make script exectuable: `chmod +x /etc/ssh/login-notify.s`
3) Edit `/etc/pam.d/sshd`, add: `session optional pam_exec.so seteuid /etc/ssh/login-notify.sh`

> [!CAUTION]
> Setting `session optional pam_exec.so seteuid /etc/ssh/login-notify.sh` to `session required ...`
> Can lead unavailable ssh login when gotify/the script fails

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

---

### QEMU/KVM Virtualization
```sh
sudo apt install qemu-kvm virt-manager virtinst libvirt-clients bridge-utils libvirt-daemon-system -y
sudo systemctl enable --now libvirtd
```

#### Add user to groups
```sh
sudo usermod -aG kvm $USER
sudo usermod -aG libvirt $USER
```

#### Start GUI
```sh
virt-manager
```

#### Install guest agent (In Rocky 9 VMs)
```sh
sudo dnf install qemu-guest-agent
```

---

### Kubernetes/k3s quick start

#### Prepare firewall/nodes
```sh
firewall-cmd --add-port=6443/tcp --permanent
firewall-cmd --add-port=2379/tcp --permanent
firewall-cmd --add-port=2380/tcp --permanent
firewall-cmd --reload
```

#### `kubectl` installation
```sh
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/
```

#### k3s installation
```sh
sudo mkdir -p /etc/rancher/k3s
sudo echo "disable: traefik" > /etc/rancher/k3s/config.yaml
curl -sfL https://get.k3s.io | sh -s - server --cluster-init
```

> [!TIP] 
> Set the env var `INSTALL_K3S_VERSION`  (e.g. `export INSTALL_K3S_VERSION=v1.28.8+k3s1`) to install a specific k3s/kubernetes version.
> Version available: https://github.com/k3s-io/k3s/releases/



#### Add nodes
server1
```sh
cat /var/lib/rancher/k3s/server/token
```

serverN
```sh
curl -sfL https://get.k3s.io | K3S_TOKEN=<Token> sh -s - server --server https://192.168.122.11:6443
```

> [!NOTE]
> Set/install the same version as on the first node
> Environment variable `INSTALL_K3S_VERSION`.
> See tip above.


#### Remove/Deinstallation
```sh
/usr/local/bin/k3s-uninstall.sh
/usr/local/bin/k3s-agent-uninstall.sh
```

#### Copy cluster config 
```sh
mkdir ~/.kube
cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
```

---

### keepalived (high availability)
#### Prepare (on all nodes!)
```
firewall-cmd --add-rich-rule='rule protocol value="vrrp" accept' --permanent
firewall-cmd --reload
```

#### Installation (& clear default config file)
```
yum install -y keepalived
: > /etc/keepalived/keepalived.conf
```


#### Node 1 (Master)
```
vrrp_instance K3S {

    state MASTER

    interface enp1s0
    virtual_router_id 10
    priority 200
    advert_int 1

    unicast_src_ip 192.168.122.11/16
    
    unicast_peer {
        192.168.122.12/16
        192.168.122.13/16
    }

    virtual_ipaddress {
	192.168.122.10/16
    }

    authentication {
        auth_type PASS
        auth_pass 1234
    }

}
```

#### Node 2 (Backup)
```
vrrp_instance K3S {

    state BACKUP

    interface enp1s0
    virtual_router_id 10
    priority 190
    advert_int 1

    unicast_src_ip 192.168.122.12/16
    
    unicast_peer {
        192.168.122.11/16
        192.168.122.13/16
    }

    virtual_ipaddress {
	192.168.122.10/16
    }

    authentication {
        auth_type PASS
        auth_pass 1234
    }

}
```

#### Node 3 (Backup)
```
vrrp_instance K3S {

    state BACKUP

    interface enp1s0
    virtual_router_id 10
    priority 180
    advert_int 1

    unicast_src_ip 192.168.122.13/16
    
    unicast_peer {
        192.168.122.11/16
        192.168.122.12/16
    }

    virtual_ipaddress {
	192.168.122.10/16
    }

    authentication {
        auth_type PASS
        auth_pass 1234
    }

}
```

### Move files from (sub) folders into cwd
```sh
find ./ -type f -exec mv -t . {} +
```

---

### Notify on systemd unit file start/stop/restart
Create unit file in `sudo vim /etc/systemd/system/openhaus-notify@.service`.
Enable notifications with:
- `systemctl enable openhaus-notify@backend`
- `systemctl enable openhaus-notify@connector`

This creates a gotify notification when the connector or backend start, stop or restart.

```systemd
[Unit]
Description=OpenHaus service notification for "%i"
After=%i.service
BindsTo=%i.service

[Service]
Type=oneshot
ExecStart=/usr/bin/curl "http://<gotify url>/message?token=<app token>" -F "title=Service started" -F "message=%i started" -F "priority=5"
ExecStop=/usr/bin/curl "http://<gotify url>/message?token=<app token>" -F "title=Service stopped" -F "message=%i stopped" -F "priority=5"
ExecReload=/usr/bin/curl "http://<gotify url>/message?token=<app token>" -F "title=Service restarted" -F "message=%i restarted" -F "priority=5"

[Install]
WantedBy=%i.service
```

### Run bash command in loop (one liner)
```sh
while true; do 'wscat --connect=ws://127.0.0.1:8080/api/events' sleep 1; done
```
