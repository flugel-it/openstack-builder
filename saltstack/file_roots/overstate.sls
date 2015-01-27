
highstate-all:
  match: '*'

ceph-mon:
  match: 'G@roles:ceph-mon'
  require:
    - highstate-all
  sls:
    - ceph
    - ceph.mon

ceph-osd:
  match: 'G@roles:ceph-osd'
  require:
    - ceph-mon
  sls:
    - ceph.osd

