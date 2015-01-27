Openstack Deployment procedures
===============================

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

