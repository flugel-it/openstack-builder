    This file is part of Openstack-Builder.

    Openstack-Builder is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Openstack-Builder is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Openstack-Builder.  If not, see <http://www.gnu.org/licenses/>.

    Copyright flugel.it LLC
    Authors: Luis Vinay <luis@flugel.it>
             Diego Woitasen <diego@flugel.it>



{%- import 'ceph/settings.sls' as ceph %}

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

/etc/ceph/ceph.client.cinder.keyring:
  file.managed:
    - source: salt://ceph/files/ceph.client.cinder.keyring
    - mode: 644

/etc/ceph/ceph.client.cinder-backup.keyring:
  file.managed:
    - source: salt://ceph/files/ceph.client.cinder-backup.keyring
    - mode: 644

ceph-all:
  service.running:
    - enable: true

