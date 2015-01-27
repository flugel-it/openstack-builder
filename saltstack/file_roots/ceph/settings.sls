{%- set mon_keyring = "/etc/ceph/ceph.mon.keyring" %}
{%- set admin_keyring = "/etc/ceph/ceph.client.admin.keyring" %}

{%- set ceph_mon_ips = [] %}
{%- set ceph_mon_hostnames = [] %}
{%- set ceph_mons = salt['mine.get']('roles:ceph-mon', 'network.ip_addrs', expr_form="grain_pcre") %}
{%- for minion, ip_addrs in ceph_mons.items() %}
  {%- do ceph_mon_ips.append(ip_addrs|first + ":6789") %}
  {%- do ceph_mon_hostnames.append(minion) %}
{%- endfor %}

