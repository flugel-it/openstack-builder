
/etc/hosts:
  file.managed:
    - source: salt://hostsfile/files/hosts.jinja
    - mode: 644
    - template: jinja

