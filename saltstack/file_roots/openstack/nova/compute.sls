
sysfsutils:
  pkg.installed

{%- if pillar.openstack.nova.compute == "nova-compute-lxd" %}

nclxd:
  pip.installed:
    - name: git+https://github.com/lxc/nova-compute-lxd@stable/kilo

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

