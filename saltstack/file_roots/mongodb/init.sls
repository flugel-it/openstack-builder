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




{% if grains.get("os") in [ "CentOS", "Redhat" ] %}

mongodb-repo:
  pkgrepo.managed:
    - humanname: mongodb
    - baseurl: http://downloads-distro.mongodb.org/repo/redhat/os/x86_64/
    - gpgcheck: 0
    - enabled: 1

#Not sure why pkg.installed doesn't work in CentOS 6 for MongoDB !?
mongodb:
  cmd.run:
    - name: yum install -y mongodb-org-server mongodb-org-shell mongodb-org-tools
    - unless: test -f /usr/bin/mongod
    - require:
      - pkgrepo: mongodb-repo

{% else %}

mongodb-repo:
  pkgrepo.managed:
    - humanname: mongodb-repo
    - name: deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen
    - dist: dist
    - file: /etc/apt/sources.list.d/mongodb-repo.list
    - keyid: 7F0CEB10
    - keyserver: keyserver.ubuntu.com

mongodb:
  pkg.installed:
    - pkgs:
      - mongodb-org-server
      - mongodb-org-shell
      - mongodb-org-tools
    - require:
      - pkgrepo: mongodb-repo

{% endif %}

mongod:
  service.running:
    - enable: true
    - require:
{% if grains.get("os") in [ "CentOS", "Redhat" ] %}
      - cmd: mongodb
{% else %}
      - pkg: mongodb
{% endif %}

/etc/mongod.conf:
  file.append:
    - text: smallfiles = true
    - watch_in:
      - service: mongod

