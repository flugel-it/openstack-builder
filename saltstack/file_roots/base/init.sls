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



{%- set hostname = grains['id'] %}

/root/.ssh:
  file.directory:
    - user: root
    - group: root
    - mode: 750

base-pkgs:
  pkg.installed:
    - pkgs:
      - ssh
      - screen
      - strace
      - tcpdump
      - ntp
      - sysstat
      - dstat
      - vim
      - unzip
      - git
      - psutils
      - bridge-utils
      - vlan
      - ifenslave
      - ethtool
      - arping
      - curl

ntp:
  service.running:
    - enable: true

{% if grains.get("os") == "Ubuntu" %}

/etc/apt/sources.list:
  file.replace:
    - pattern: '^# *(deb http://.*)'
    - repl: '\g<1>'

apt-get update:
  cmd.wait:
    - order: 0
    - watch:
      - file: /etc/apt/sources.list

/etc/default/sysstat:
  file.replace:
    - pattern: ^ENABLED.*
    - repl: ENABLED="true"
    - watch_in:
      - service: sysstat

{% endif %}

{% if grains.get("os") in [ "CentOS", "Redhat" ] %}

selinux-disabled:
  file:
    - replace
    - name: /etc/selinux/config
    - pattern: SELINUX=.*
    - repl: SELINUX=disabled

{% endif %}

sysstat:
  service.running:
    - enable: true
    - watch:
      - pkg: base-pkgs

#OpenSSL always the latest version, Heartbleed protection :)
{% if grains.get("os") == "CentOS" %}

openssl:
  pkg.latest

{% elif grains.get("os") == "Ubuntu" %}

openssl:
  pkg.latest

libssl1.0.0:
  pkg.latest

{% endif %}

/root/.ssh/authorized_keys:
  file.managed:
    - user: root
    - group: root
    - mode: 400
    - source: salt://base/files/root_authorized_keys

/etc/resolv.conf:
  file.managed:
    - contents: "nameserver 8.8.8.8\n"

