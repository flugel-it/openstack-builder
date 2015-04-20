Openstack Deployment procedures
===============================

## Controller VM

```
apt-get install virtinst qemu-kvm virt-viewer
virt-install \
--connect qemu:///system \
--name globant-glx-co01 \
--ram 4096 \
--vcpus 2 \
--file /var/lib/libvirt/images/globant-glx-co01.img \
--file-size=25 \
--location http://us.archive.ubuntu.com/ubuntu/dists/trusty/main/installer-amd64/ \
--virt-type kvm \
--vnc \
--os-variant ubuntutrusty \
--network bridge=br0 \
--extra-args "auto=true 
url=http://cloud-master.flugel.it/openstack-builder.seed
netcfg/get_ipaddress=172.28.152.10 netcfg/get_netmask=255.255.255.0
netcfg/get_gateway=172.28.152.254 netcfg/get_nameservers=8.8.8.8
netcfg/disable_dhcp=true"
```

## With salt-cloud ##

```
cd /root/openstack-builder/saltstack/salt-cloud
salt-cloud -m openstack-rax.map -y # or openstac-do.map
```

## Without salt-cloud ##


```
wget -O bootstrap-salt.sh https://bootstrap.saltstack.com
sh bootstrap-salt.sh -P -A 188.166.54.47  git v2014.7.0
=======
salt '*' grains.setval cluster_name [cluster_name]

salt [controller_node] grains.setval roles ['openstack-controller']
salt [network_node] grains.setval roles ['openstack-network']
salt [compute_node] grains.setval roles ['openstack-compute']
```

## All ##

```
CLUSTERNAME=$1

salt -t 300 -v -G cluster_name:$CLUSTERNAME \
        saltutil.sync_all
salt -t 300 -v -G cluster_name:$CLUSTERNAME \
<<<<<<< HEAD
        saltutil.refresh_pillar
salt -t 300 -v -G cluster_name:$CLUSTERNAME \
=======
>>>>>>> f53cedf95100bb61a1a05ff574028996e49416fc
        state.sls base,openstack,salt-minion
salt -t 300 -v -G cluster_name:$CLUSTERNAME \
        state.sls salt-minion,hostsfile,openstack.minion 
salt -t 300 -v -C "G@cluster_name:$CLUSTERNAME and G@roles:openstack-controller" \
        state.sls salt-minion,mysql,rabbitmq 
salt -t 300 -v -C "G@cluster_name:$CLUSTERNAME and G@roles:openstack-controller" \
        state.sls openstack,openstack.controller,openstack.keystone
salt -t 300 -v -G cluster_name:$CLUSTERNAME \
        state.highstate
```

## With salt-cloud ##

```
cd /root/openstack-builder/saltstack/salt-cloud
salt-cloud -m openstack-rax.map -y # or openstac-do.map
```

## Without salt-cloud ##

```
salt '*' grains.setval cluster_name [cluster_name]

salt [controller_node] grains.setval roles ['openstack-controller']
salt [network_node] grains.setval roles ['openstack-network']
salt [compute_node] grains.setval roles ['openstack-compute']
```


```
neutron net-create ext-net --shared --router:external True \
  --provider:physical_network external --provider:network_type flat
neutron subnet-create ext-net --name ext-subnet \
  --allocation-pool start=162.243.213.238,end=162.243.213.238 \
  --disable-dhcp --gateway 162.243.213.1 162.243.213.238/24
neutron net-create demo-net
neutron subnet-create demo-net --name demo-subnet \
  --gateway 192.168.1.1 192.168.1.0/24
neutron router-create demo-router
neutron router-interface-add demo-router demo-subnet
neutron router-gateway-set demo-router ext-net
```

```
nova keypair-add --pub-key ~/.ssh/authorized_keys demo-key
NET_ID=$(neutron net-show demo-net | grep '| id' | awk '{ print $4; }')
nova boot --flavor m1.small --image "Ubuntu 14.04 Trusty" \
  --nic net-id=$NET_ID \
  --security-group default --key-name demo-key demo-instance1
```

