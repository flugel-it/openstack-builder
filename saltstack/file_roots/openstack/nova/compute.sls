
sysfsutils:
  pkg.installed

{%- if pillar.openstack.nova.compute == "nova-compute-lxd" %}

nclxd_reqs:
  file.managed:
    - name: /var/tmp/nclxd_reqs.txt
    - source: https://raw.githubusercontent.com/flugel-it/nova-compute-lxd/master/requirements.txt
    - source_hash: md5=1a7e9be21215dbe02708c79a875dd378
  pip.installed:
    - requirements: /var/tmp/nclxd_reqs.txt

pylxd:
  pip.installed:
    - name: git+https://github.com/flugel-it/pylxd
    - require:
      - file: nclxd_reqs

nclxd:
  pip.installed:
    - name: git+https://github.com/flugel-it/nova-compute-lxd
    - require:
      - pip: pylxd
    - watch_in:
      - service: nova-compute

lxd_ppa:
  pkgrepo.managed:
    - ppa: ubuntu-lxc/lxd-stable

lxd:
  pkg.installed

/etc/subuid:
  file.managed:
    - mode: 644
    - contents: |
        lxd:100000:65536
        nova:100000:65536
        root:100000:65536

/etc/subgid:
  file.managed:
    - mode: 644
    - contents: |
        lxd:100000:65536
        nova:100000:65536
        root:100000:65536

lxd_group:
  group.present:
    - name: lxd
    - members:
      - nova

/var/lib/lxd/lxc:
  file.directory

/etc/nova/rootwrap.d/tar.filters:
  file.managed:
    - contents: |
        [Filters]
        tar: CommandFilter, tar, root

# We need to run this because it needs to initialize some certificates.
# BTW, check it again in the future.
lxc list:
  cmd.run

# We need it in Ubuntu 14.04 because we need support for overlayfs.
linux-image-3.19.0-28-generic:
  pkg.installed

{%- else %}

{{ pillar.openstack.nova.compute }}:
  pkg.installed

{%- endif %}

nova-compute:
  pkg.installed: []
  service.running:
    - watch:
      - file: /etc/nova/nova.conf
      - file: /etc/nova/nova-compute.conf

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

{% if pillar.get("ceph", {}).get("enabled") %}

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

# Config for migration/live-migration
# XXX: fix harcoded user
# XXX: fix harcoded keys, they should in a pillar

/var/lib/nova/.ssh:
   file.directory:
    - user: nova
    - group: nova
    - mode: 750

/var/lib/nova/.ssh/id_rsa:
  file.managed:
    - source: salt://openstack/nova/files/nova.key
    - user: nova
    - group: nova
    - mode: 600

/var/lib/nova/.ssh/id_rsa.pub:
  file.managed:
    - source: salt://openstack/nova/files/nova.key.pub
    - user: nova
    - group: nova

/var/lib/nova/.ssh/authorized_keys:
  file.managed:
    - source: salt://openstack/nova/files/nova.key.pub
    - user: nova
    - group: nova

/var/lib/nova/.ssh/config:
  file.managed:
    - source: salt://openstack/nova/files/ssh_config
    - user: nova
    - group: nova
    - mode: 644
