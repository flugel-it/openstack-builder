{%- set mon_keyring = "/etc/ceph/ceph.mon.keyring" %}
{%- set admin_keyring = "/etc/ceph/ceph.client.admin.keyring" %}

{%- set ceph_mon_ips = [] %}
{%- set ceph_mon_hostnames = [] %}
{%- set ceph_mons = salt['mine.get']('roles:ceph-mon', 'network.ip_addrs', expr_form="grain_pcre") %}
{%- for minion, ip_addrs in ceph_mons.items() %}
  {%- do ceph_mon_ips.append(ip_addrs|first + ":6789") %}
  {%- do ceph_mon_hostnames.append(minion) %}
{%- endfor %}

ceph-get-key:
  cmd.run:
    - name: gpg --keyserver pgpkeys.mit.edu --recv-key 7EBFDD5D17ED316D
    - unless: gpg --list-keys | grep 17ED316D

ceph-add-key:
  cmd.run:
    - name: gpg -a --export 7EBFDD5D17ED316D | apt-key add -
    - unless: apt-key list | grep 17ED316D

ceph-repo:
  pkgrepo.managed:
    - name: deb http://download.ceph.com/ceph/latest/ubuntu/ {{ grains['lsb_distrib_codename'] }} main
    - humanname: Ceph Repo
    - dist: {{ grains['lsb_distrib_codename'] }}
    - file: /etc/apt/sources.list.d/ceph.list
    - require:
      - cmd: ceph-add-key

ceph:
  pkg.installed:
    - refresh: true

/etc/ceph/ceph.conf:
  file.managed:
    - source: salt://ceph/files/ceph.conf
    - template: jinja
    - mode: 644
    - context:
      ceph_mon_hostnames: {{ ceph_mon_hostnames|join(",") }}
      ceph_mon_ips: {{ ceph_mon_ips|join(",") }}
    - require:
      - pkg: ceph
      - pkgrepo: ceph-repo

ceph-mon-keyring:
  file.managed:
    - name: {{ mon_keyring }}
    - source: salt://ceph/files/ceph.mon.keyring
    - mode: 640

ceph-admin-keyring:
  file.managed:
    - name: {{ admin_keyring }}
    - source: salt://ceph/files/ceph.client.admin.keyring
    - mode: 640

{%- set mon_map = "/etc/ceph/monmap" %}
{%- set map_create_cmd = [ "monmaptool --create --clobber --fsid " + pillar["ceph_fsid"] ]%}
{%- for ceph_mon_hostname, ceph_mon_ip in ceph_mons.items() %}
{%- do map_create_cmd.append("--add " + ceph_mon_hostname + " " + ceph_mon_ip|first + ":6789") %}
{%- endfor %}
{%- do map_create_cmd.append(mon_map) %}

ceph-map-create:
  cmd.run:
    - name: {{ map_create_cmd|join(" ") }}
    - creates: /etc/ceph/monmap

{% set mon_dir = "/var/lib/ceph/mon/" + pillar["ceph_name"] + "-" + grains["id"] %}
ceph-dir-create:
  file.directory:
    - name: {{ mon_dir }}

ceph-mon-init:
  cmd.run:
    - name: ceph-mon --mkfs -i {{ grains["id"] }} --monmap {{ mon_map }} --keyring {{ mon_keyring }}
    - creates: {{ mon_dir }}/keyring
    - require:
      - cmd: ceph-map-create
      - file: ceph-mon-keyring

{{ mon_dir }}/done:
  file.touch:
    - requires:
      - cmd: ceph-mon-init

{{ mon_dir }}/upstart:
  file.touch:
    - requires:
      - cmd: ceph-mon-init

ceph-all:
  service.running:
    - watch: 
      - cmd: ceph-mon-init

