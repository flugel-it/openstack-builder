{%- import 'ceph/settings.sls' as ceph %}

ceph-add-key:
  cmd.run:
    - name: wget -q -O- 'https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc' | sudo apt-key add -
    - unless: apt-key list | grep 17ED316D

ceph-repo:
  pkgrepo.managed:
    - name: deb http://download.ceph.com/debian-hammer/ {{ grains['lsb_distrib_codename'] }} main
    - humanname: Ceph Repo
    - dist: {{ grains['lsb_distrib_codename'] }}
    - file: /etc/apt/sources.list.d/ceph.list
    - require:
      - cmd: ceph-add-key

ceph:
  pkg.installed

python-ceph:
  pkg.installed

/etc/ceph/ceph.conf:
  file.managed:
    - source: salt://ceph/files/ceph.conf
    - template: jinja
    - mode: 644
    - context:
      ceph_mon_hostnames: {{ ceph.ceph_mon_hostnames|join(",") }}
      ceph_mon_ips: {{ ceph.ceph_mon_ips|join(",") }}
    - require:
      - pkg: ceph
      - pkgrepo: ceph-repo

ceph-mon-keyring:
  file.managed:
    - name: {{ ceph.mon_keyring }}
    - source: salt://ceph/files/ceph.mon.keyring
    - mode: 640

#XXX: fix mode. Allow read access to a specific group !?
ceph-admin-keyring:
  file.managed:
    - name: {{ ceph.admin_keyring }}
    - source: salt://ceph/files/ceph.client.admin.keyring
    - mode: 644

ceph-all:
  service.running:
    - enable: true

