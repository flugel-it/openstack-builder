{%- import 'ceph/settings.sls' as ceph %}

#XXX: make this a pillar/grain
/var/spool/osd1:
  file.directory

ceph-osd-prepare:
  cmd.run:
    - name: ceph-disk prepare --cluster {{ pillar["ceph_name"] }} --cluster-uuid {{ pillar["ceph_fsid"] }} /var/spool/osd1
    - creates: /var/spool/osd1/magic

ceph-osd-activate:
  cmd.run:
    - name: ceph-disk activate /var/spool/osd1

