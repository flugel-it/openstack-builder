
keystone.endpoint: http://{{ salt.openstack.get_controller() }}:35357/v2.0

openstack:
  region: RegionOne
  cinder:
    driver: null
  horizon: 
    ssl_key: null


