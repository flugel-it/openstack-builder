
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

{%- if pillar.openstack.cinder.driver == "ceph" %}

/etc/ceph/ceph.client.cinder.keyring:
  file.managed:
    - source: salt://openstack/cinder/files/ceph.client.cinder.keyring
    - mode: 644

/etc/ceph/ceph.client.cinder-backup.keyring:
  file.managed:
    - source: salt://openstack/cinder/files/ceph.client.cinder-backup.keyring
    - mode: 644

ceph_cinder_key:
  cmd.run:
    - name: ceph auth import -i /etc/ceph/ceph.client.cinder.keyring
    - unless: ceph auth get client.cinder

ceph_cinder_backup_key:
  cmd.run:
    - name: ceph auth import -i /etc/ceph/ceph.client.cinder-backup.keyring
    - unless: ceph auth get client.cinder-backup

{% endif %}

