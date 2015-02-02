
# We need it now, because it's required to render some templates using
# the keystone Salt module.
python-keystoneclient:
  pkg.installed

/etc/salt/minion.d/openstack.conf:
  file.absent

