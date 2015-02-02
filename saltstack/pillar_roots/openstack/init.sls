
{%- if "openstack-controller" in grains.get("roles", {}) %}
keystone.endpoint: http://localhost:35357/v2.0
{%- endif %}

openstack:
  region: RegionOne
  cinder:
    driver: null
  horizon: 
    ssl_key: null

