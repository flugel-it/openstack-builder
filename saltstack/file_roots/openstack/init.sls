
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
    - name: deb http://ubuntu-cloud.archive.canonical.com/ubuntu trusty-updates/{{ pillar.openstack.release}} main
    - dist: trusty-updates/{{ pillar.openstack.release }}
    - file: /etc/apt/sources.list.d/cloud-archive.list
    - keyid: EC4926EA
    - keyserver: keyserver.ubuntu.com  

python-openstackclient:
  pkg.installed

