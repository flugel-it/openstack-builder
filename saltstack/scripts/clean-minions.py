#!/usr/bin/env python

import os
import warnings
warnings.filterwarnings("ignore")

import salt.client
from salt.key import Key

master_opts = salt.config.master_config(
    os.environ.get('SALT_MASTER_CONFIG', '/etc/salt/master'))

salt_key = Key(master_opts)
local = salt.client.LocalClient()

minions = salt_key.list_keys()["minions"]

ping_result = local.cmd('*', 'test.ping', timeout=30)

for minion in minions:
    if not ping_result.get(minion):
        salt_key.delete_key(minion)

