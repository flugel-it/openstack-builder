
#pkgs required by stock and custom modules
salt-mine-pkgs:
  pkg.installed:
    - pkgs:
      - python-psutil
      - python-ipy
      - python-pip
      - python-dev
      - build-essential

python-netifaces:
  pkg.removed

netifaces:
  pip.installed

salt-minion:
  service.running:
    - enable: true

salt-mine:
  file.managed:
    - name: /etc/salt/minion.d/mine.conf
    - source: salt://salt-minion/files/salt-mine.conf
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: salt-minion

salt-tcp:
  file.managed:
    - name: /etc/salt/minion.d/tcp.conf
    - source: salt://salt-minion/files/tcp.conf
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: salt-minion

