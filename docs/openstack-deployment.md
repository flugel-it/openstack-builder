Openstack Deployment procedures
===============================

```
saltutil.sync_all
state.sls hostsfile,salt-minion,openstack.minion
*controller* state.sls mysql,rabbitmq
state.highstate
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

