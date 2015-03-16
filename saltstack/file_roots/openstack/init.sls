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




/etc/sysctl.d/99-disable-ipv6.conf:
  file.managed:
    - contents: "net.ipv6.conf.all.disable_ipv6=1\n"
    - watch_in: 
      - cmd: sysctl-update

sysctl-update:
  cmd.wait:
    - name: sysctl --system

openstack-base-pkgs:
  pkg.installed:
    - pkgs:
      - {{ pillar.pkgs.python_mysqldb }}
      - {{ pillar.pkgs.python_software_properties }}
{%- if pillar.openstack.cinder.get("driver") == "nfs" %}
      - nfs-common
{% endif %}

openstack-ppa:
  pkgrepo.managed:
    - humanname: Cloud Archive PPA
    - name: deb http://ubuntu-cloud.archive.canonical.com/ubuntu trusty-updates/juno main
    - dist: trusty-updates/juno
    - file: /etc/apt/sources.list.d/cloud-archive.list
    - keyid: EC4926EA
    - keyserver: keyserver.ubuntu.com  

