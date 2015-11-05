
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
        root:100000:65536

/etc/subgid:
  file.managed:
    - mode: 644
    - contents: |
        lxd:100000:65536
        root:100000:65536

lxd_group:
  group.present:
    - name: lxd

/var/lib/lxd/lxc:
  file.directory
