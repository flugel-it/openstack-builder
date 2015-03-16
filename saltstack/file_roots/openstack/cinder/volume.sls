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




cinder-volume:
  pkg.installed: []
  service.running:
    - watch:
      - file: /etc/cinder/cinder.conf
    
# Required when we have a ISCSI cinder backend and we want to use a volume as
# root disk. Cinder volume needs to map the block device to copy the image
# from Glance.
open-iscsi:
  pkg.installed: []
  service.running: []

sysfsutils:
  pkg.installed

open-iscsi-setup:
  cmd.run:
    - name: |
        cat << EOF > /etc/iscsi/initiatorname.iscsi
        InitiatorName=$(/usr/sbin/iscsi-iname)
        InitiatorAlias=$(hostname)
        EOF
    - unless: test -f /etc/iscsi/initiatorname.iscsi
    - watch_in:
      - service: cinder-volume
      - service: open-iscsi

{%- if pillar.openstack.cinder.driver == "nfs" %}

/etc/cinder/nfs_shares:
  file.managed:
    - source: salt://openstack/cinder/files/nfs_shares
    - template: jinja
    - watch_in:
      - service: cinder-volume

{% endif %}

