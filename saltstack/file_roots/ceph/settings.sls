{%- set mon_keyring = "/etc/ceph/ceph.mon.keyring" %}
{%- set admin_keyring = "/etc/ceph/ceph.client.admin.keyring" %}

{%- set ceph_mon_ips = [] %}
{%- set ceph_mon_hostnames = [] %}
{%- set ceph_mons = salt['mine.get']('roles:ceph-mon', 'grains.item', expr_form="grain_pcre") %}
{%- for minion, minion_grains in ceph_mons.iteritems() %}
  {%- do ceph_mon_ips.append(grains.fqdn_ip4|first + ":6789") %}
  {%- do ceph_mon_hostnames.append(minion) %}
{%- endfor %}

