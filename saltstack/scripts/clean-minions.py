    This file is part of Openstack-Builder.

    Openstack-Builder is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Openstack-Builder is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Openstack-Builder.  If not, see <http://www.gnu.org/licenses/>.

    Copyright flugel.it LLC
    Authors: Luis Vinay <luis@flugel.it>
             Diego Woitasen <diego@flugel.it>



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

