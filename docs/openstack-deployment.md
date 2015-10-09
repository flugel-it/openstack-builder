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

## Before deploy

1. Define the pillar for cluster. Examples below
2. Generate the password pillar sls.

pillars/top.sls:

```
  'G@cluster_name:newcluster':
    - match: compound
    - clusters
    - clusters.newcluster
    - clusters.newcluster-password
```

pillars/cluster/newcluster.sls:

```
networks:
  public: 0.0.0.0/0
  private: 0.0.0.0/0

openstack:
  external_iface: dummy0
  cinder:
    driver: null

  horizon:
    ssl_key: null
    ssl_crt: null

  neutron:
    dnsmasq_opts:
      - dhcp-option-force=26,1450

```

## With salt-cloud ##

```
cd /root/openstack-builder/saltstack/salt-cloud
salt-cloud -m openstack-rax.map -y # or openstac-do.map
```

## Without salt-cloud ##


```
wget -O bootstrap-salt.sh https://bootstrap.saltstack.com
sh bootstrap-salt.sh -P -A 188.166.54.47  git v2014.7.5

salt 'cluster*' grains.setval cluster_name [cluster_name]

salt [controller_node] grains.setval roles ['openstack-controller']
salt [network_node] grains.setval roles ['openstack-network']
salt [compute_node] grains.setval roles ['openstack-compute']
```

## Orchestrated deploy

```
salt-run state.orchestrate orchestration.openstack pillar=' cluster_name: dolab
' | tee /tmp/orchestrate
```

## Manual deploy ##

```
CLUSTERNAME=$1
TIMEOUT=300

salt -t $TIMEOUT -v -G cluster_name:$CLUSTERNAME \
        saltutil.sync_all
salt -t $TIMEOUT -v -G cluster_name:$CLUSTERNAME \
        saltutil.refresh_pillar
salt -t $TIMEOUT -v -G cluster_name:$CLUSTERNAME \
        state.sls base,openstack,salt-minion
salt -t $TIMEOUT -v -G cluster_name:$CLUSTERNAME \
        state.sls salt-minion,hostsfile,openstack.minion 
salt -t $TIMEOUT -v -C "G@cluster_name:$CLUSTERNAME and G@roles:openstack-controller" \
        state.sls salt-minion,mysql,rabbitmq 
salt -t $TIMEOUT -v -C "G@cluster_name:$CLUSTERNAME and G@roles:openstack-controller" \
        state.sls openstack,openstack.controller,openstack.keystone
salt -t $TIMEOUT -v -G cluster_name:$CLUSTERNAME \
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
neutron net-create ext-net --shared --router:external \
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
nova boot --flavor m1.small --image "Ubuntu 14.04 Trusty 64-bit" \
  --nic net-id=$NET_ID \
  --security-group default --key-name demo-key demo-instance1
```

## Using nova-compute-lxd

```
wget
https://cloud-images.ubuntu.com/trusty/current/trusty-server-cloudimg-amd64-root.tar.gz
glance image-create --name='trusty-lxc' --container-format=bare --disk-format=raw \
< trusty-server-cloudimg-amd64-root.tar.gz
nova keypair-add --pub-key ~/.ssh/authorized_keys demo-key
NET_ID=$(neutron net-show demo-net | grep '| id' | awk '{ print $4; }')
nova boot --flavor m1.small --image "trusty-lxc" \
  --nic net-id=$NET_ID \
  --security-group default --key-name demo-key demo-instance1
```
