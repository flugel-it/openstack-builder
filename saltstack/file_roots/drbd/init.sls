
drbd-create-lv:
  cmd.run:
    - name: lvcreate -L100G -n drbd vg00
    - unless: test -e /dev/vg00/drbd

drbd-pkgs:
  pkg.installed:
    - pkgs:
      - drbd8-utils
      - drbdlinks

