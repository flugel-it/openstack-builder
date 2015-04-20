#!/usr/bin/env python

#
# Usage:
#
#   change-hostname.py [current_name] [new_name]
# 

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
        raise Exception("No target.")

    result = local.cmd(target, cmd, *args, **kwargs)

    if cmd in [ "state.sls", "state.highstate" ]:
        for minion, states in result.iteritems():
            if type(states) == dict and states:
                for state, info in states.iteritems():
                    if type(info) == dict and not info.get("result"):
                        pprint(info)
                        raise Exception(("%s:%s failed on %s" % 
                            (cmd, state, minion)))
            else:
                print minion, states
                print 'FAIL:', minion, cmd
    elif cmd not in ["saltutil.sync_modules"]:
        if len(result) == 0:
            raise Exception("Command %s failed on %s: %s" % (cmd, target, result))

    print 'target=' + target, cmd, result

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

for i in xrange(60):
    minions = salt_key.list_keys().get("minions_pre")
    if len(minions) > 0 and new_hostname in minions:
        salt_key.accept(new_hostname)
        salt_key.delete_key(old_hostname)
        break
    sleep(2)

#XXX: I won't like this, we have to wait and try twice !?
sleep(10)
try:
    salt_cmd('test.ping', name=new_hostname, timeout=60)
except:
    salt_cmd('test.ping', name=new_hostname, timeout=60)

