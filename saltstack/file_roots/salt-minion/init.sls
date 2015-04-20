
#pkgs required by stock and custom modules
salt-mine-pkgs:
  pkg.installed:
    - pkgs:
      - python-dev
      - python-setuptools
      - build-essential

python-pip:
  pkg.removed

python-psutil:
  pkg.removed

python-ipy:
  pkg.removed

python-netifaces:
  pkg.removed

pip-install:
  cmd.run:
    - name: easy_install pip
    - unless: test -f /usr/local/bin/pip
    - reload_modules: True
    - require:
      - pkg: salt-mine-pkgs

{%- for pip_pkg in [ "psutil", "IPy", "netifaces" ] %}

{{ pip_pkg }}:
  pip.installed:
    - require:
      - cmd: pip-install
    - watch_in:
      - service: salt-minion

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

