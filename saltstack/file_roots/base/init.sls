{%- set hostname = grains['id'] %}

/root/.ssh:
  file.directory:
    - user: root
    - group: root
    - mode: 750

base-pkgs:
  pkg.installed:
    - pkgs:
      - screen
      - strace
      - tcpdump
      - ntp
      - sysstat
      - vim
      - unzip
      - git

ntp:
  service.running:
    - enable: true

{% if grains.get("os") == "Ubuntu" %}

/etc/apt/sources.list:
  file.replace:
    - pattern: '^# *(deb http://.*)'
    - repl: '\g<1>'

apt-get update:
  cmd.wait:
    - order: 0
    - watch:
      - file: /etc/apt/sources.list

/etc/default/sysstat:
  file.replace:
    - pattern: ^ENABLED.*
    - repl: ENABLED="true"
    - watch_in:
      - service: sysstat

{% endif %}

{% if grains.get("os") in [ "CentOS", "Redhat" ] %}

selinux-disabled:
  file:
    - replace
    - name: /etc/selinux/config
    - pattern: SELINUX=.*
    - repl: SELINUX=disabled

{% endif %}

sysstat:
  service.running:
    - enable: true
    - watch:
      - pkg: base-pkgs

#OpenSSL always the latest version, Heartbleed protection :)
{% if grains.get("os") == "CentOS" %}

openssl:
  pkg.latest

{% elif grains.get("os") == "Ubuntu" %}

openssl:
  pkg.latest

libssl1.0.0:
  pkg.latest

{% endif %}

