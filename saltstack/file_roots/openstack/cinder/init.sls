
openstack-cinder-pkgs:
  pkg.installed:
    - pkgs:
      - python-cinderclient
      - cinder-common

{%- for dir in [ "/etc/cinder", "/var/log/cinder" ] %}

{{ dir }}:
  file.directory:
    - mode: 755
    - user: cinder
    - group: cinder

{%- endfor %}

/etc/cinder/cinder.conf:
  file.managed:
    - source: salt://openstack/cinder/files/cinder.conf
    - template: jinja
    - context:
      controller: {{ salt.openstack.get_controller() }}
      private_ip: {{ salt.openstack.get_private_ip() }}
    - user: cinder
    - group: cinder
    - mode: 640

