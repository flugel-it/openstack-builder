
cinder-volume:
  pkg.installed: []
  service.running:
    - watch:
      - file: /etc/cinder/cinder.conf

{%- if pillar.openstack.cinder.driver == "nfs" %}

/etc/cinder/nfs_shares:
  file.managed:
    - source: salt://openstack/cinder/files/nfs_shares
    - template: jinja
    - watch_in:
      - service: cinder-volume

{% endif %}

