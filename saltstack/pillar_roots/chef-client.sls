
chef:
  ntp_sync: False
  lookup:
    client: chef-client
    confdir: /etc/chef
  client_rb:
    chef_server_url: https://atlas-control.woitasen.com.ar
    log_level: :info
    log_location: "'/var/log/chef-client.log'"
    validation_client_name: chef-validator
    validation_key: /etc/chef/validation.pem
  validation_pem: |
    text
