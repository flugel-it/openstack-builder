#!/usr/bin/env python

import os
import sys
import warnings
warnings.filterwarnings("ignore")

from time import sleep

import salt.client
from salt.key import Key

def salt_cmd(cmd, *args, **kwargs):
    kwargs.setdefault("timeout", 120)

    minion = kwargs.get("name")
    role = kwargs.get("role")
    cluster_name = kwargs.get("cluster_name")

    if minion:
        target = minion
    elif cluster_name:
        if not role:
            kwargs["expr_form"] = "grain"
            target = 'cluster_name:' + cluster_name
        else:
            kwargs["expr_form"] = "compound"
            target = 'G@cluster_name:' + cluster_name
            if role:
                target += ' and G@roles:' + role
    else:
        print 'XXX', minion, role, cluster_name
        die("No target.")

    result = local.cmd(target, cmd, *args, **kwargs)

    if cmd in [ "state.sls", "state.highstate" ]:
        for minion, states in result.iteritems():
            if type(states) == dict and states:
                for state, info in states.iteritems():
                    if type(info) == dict and not info.get("result"):
                        pprint(info)
                        die("%s:%s failed on %s" % (cmd, state, minion))
            else:
                print minion, states
                print 'FAIL:', minion, cmd

    print 'target=' + target, result

    return result

old_hostname = sys.argv[1]
new_hostname = sys.argv[2].lower()

master_opts = salt.config.master_config(
    os.environ.get('SALT_MASTER_CONFIG', '/etc/salt/master'))

salt_key = Key(master_opts)
local = salt.client.LocalClient()

salt_cmd('saltutil.sync_modules', name=old_hostname, timeout=30)

salt_cmd('miscutils.set_hostname', [ new_hostname ],
    name=old_hostname, timeout=30)

sleep(2)
salt_key.accept(new_hostname)

salt_cmd('test.ping', name=new_hostname, timeout=30)

