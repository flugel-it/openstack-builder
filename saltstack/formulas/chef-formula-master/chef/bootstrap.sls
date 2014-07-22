# Include :download:`map file <map.jinja>` of OS-specific package names and
# file paths. Values can be overridden via Pillar.
{% from "chef/map.jinja" import chef with context %}

{% if salt['pillar.get']('chef:ntp_sync') == True %}
include:
  - ntp.ntpdate

ntp_sync:
  cmd:
    - run
    - name: ntpdate -u {{ salt['pillar.get']('ntp:servers', [
        '0.north-america.pool.ntp.org',
        '1.north-america.pool.ntp.org',
        '2.north-america.pool.ntp.org',
        '3.north-america.pool.ntp.org',
      ])|join(' ') }}
    - require:
      - pkg: ntpdate
{% endif %}

# Put the ``client.rb`` file in place
chef_confdir:
  file:
    - directory
    - name: {{ chef.confdir }}

chef_config:
  file:
    - managed
    - name: {{ chef.confdir }}/client.rb
    - contents: |
        log_level {{ salt['pillar.get']('chef:client_rb:log_level', ':info') }}
        log_location {{ salt['pillar.get']('chef:client_rb:log_location', 'STDOUT') }}
        chef_server_url "{{ salt['pillar.get']('chef:client_rb:chef_server_url') }}"
        validation_client_name "{{ salt['pillar.get']('chef:client_rb:validation_client_name', 'chef-validator') }}"
        validation_key "{{ chef.confdir }}/validation.pem"
        {{ salt['pillar.get']('chef:client_rb:additional_config') | indent(8) }}
    - require:
      - file: chef_confdir

chef_validation:
  file:
    - managed
    - name: {{ chef.confdir }}/validation.pem
    - source: salt://chef-server/files/chef-validator.pem
    - require:
      - file: chef_confdir

# Download and execute the Chef bootstrap bash script
curl:
  pkg:
    - installed

bootstrap_chef:
  cmd:
    - run
    - name: curl -L https://www.opscode.com/chef/install.sh | bash
    - unless: which {{ chef.client }}
    - require:
      - pkg: curl

# Do the initial Chef client run
initial_chef_run:
  cmd:
    - run
    - name: chef-client
    - require:
      - cmd: bootstrap_chef
      - file: chef_config
      - file: chef_validation
{% if salt['pillar.get']('chef:ntp_sync') == True %}
      - cmd: ntp_sync
{% endif %}

# Remove the validation.pem file if the inital run successfully produced
# ``client.pem``
chef_client_pem:
  file:
    - exists
    - name: {{ chef.confdir }}/client.pem
    - require:
      - cmd: initial_chef_run

chef_validation_rm:
  file:
    - absent
    - name: {{ chef.confdir }}/validation.pem
    - require:
      - file: chef_client_pem
