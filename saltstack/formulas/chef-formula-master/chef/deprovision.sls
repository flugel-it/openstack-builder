# This script is to be called from the reactor system
{% set hostname = data['name'] %}

delete_node:
  cmd.cmd.run:
    - tgt: chef_main # id of chef server
    - arg:
      - knife node delete {{ hostname }} -y

delete_client:
  cmd.cmd.run:
    - tgt: chef_main # id of chef server
    - arg:
      - knife client delete {{ hostname }} -y 
