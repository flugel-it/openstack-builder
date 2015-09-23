
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

{%- if pillar.get('ceilometer') %}
ceilometer-agent-compute:
  pkg.installed

# USO EL LA MISMA CONF FILE, QUE SE DA CUENTA SI ES UN COMPUTE
# Y COMENTA LA CONNECCION A LA DB
ceilometer.conf:
  file.managed:
    - source: salt://openstack/ceilometer/files/ceilometer.conf
    - template: jinja
    - mode: 750
    - watch_in:
      - service: ceilometer-agent-central
{%- endif %}

{%- if pillar.ceph.enabled %}

/var/tmp/libvirt-ceph.xml:
  file.managed:
    - source: salt://openstack/nova/files/libvirt-ceph.xml
    - template: jinja

libvirt-ceph-secret-define:
  cmd.run:
    - name: virsh secret-define --file /var/tmp/libvirt-ceph.xml
    - unless: virsh secret-list | grep ceph

libvirt-ceph-secret-set:
  cmd.run:
    - name: virsh secret-set-value --secret 457eb676-33da-42ec-9a8c-9293d545c337 --base64 $(ceph auth get-key client.admin)

{%- endif %}

