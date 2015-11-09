
#pkgs required by stock and custom modules
salt-mine-pkgs:
  pkg.installed:
    - pkgs:
      - python-dev
      - python-setuptools
      - build-essential
      - python-dev
      - python-psutil
    - reload_modules: true

python-ipy:
  pkg.removed

python-netifaces:
  pkg.removed

{%- for pip_pkg in [ "IPy", "netifaces" ] %}

{{ pip_pkg }}:
  pip.installed:
    - watch_in:
      - service: salt-minion
    - reload_modules: true

{%- endfor %}

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

