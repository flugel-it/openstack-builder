
sysfsutils:
  pkg.installed

{%- for pkg in pillar.pkgs.nova_compute %}

openstack-{{ pkg }}:
  pkg.installed:
    - name: {{ pkg }}

{{ pkg }}-service:
  service.running:
    - name: {{ pkg }}
    - watch:
      - file: /etc/nova/nova.conf
      - file: /etc/nova/nova-compute.conf

{%- endfor %}


/etc/nova/nova-compute.conf:
  file.managed:
    - source: salt://openstack/nova/files/nova-compute.conf
    - template: jinja

