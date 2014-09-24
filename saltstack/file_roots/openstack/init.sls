
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
      - python-mysqldb

