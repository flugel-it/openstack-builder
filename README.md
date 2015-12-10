OpenStack Builder
=================

# http://flugel.it

Diego Woitasen: diego@flugel.it 
Luis Vinay: luis@flugel.it


Installs a Debian based node to be used for Openstack and:
- Saltstack minion

Default user
------------

username: flugel
password: @flugel.it

Development environment setup
-----------------------------

```
apt-get install -y git screen lsb-release make
git clone git@bitbucket.org:flugel-it/openstack-builder.git
cd openstack-builder/saltstack
make
```

Boostrap SaltStack Minion
-------------------------

```
wget -O salt-boostrap.sh https://bootstrap.saltstack.com
sh salt-boostrap.sh -P -A cloud-master.flugel.it
```



