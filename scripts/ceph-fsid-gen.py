#!/usr/bin/python

#
# This is a simple script to generate pretty strong passwords to be used
# in a Openstack implementation.
#
# Luis Vinay - luis@flugel.it
#

import os,binascii
from string import join

# 30189296-d735-4a1e-9ade-588d5015342e

passseq = (8, 4, 4, 12)
new_fsid = []

for l in passseq:
    new_fsid.append(binascii.b2a_hex(os.urandom(l))[:l])

new_fsid = join(new_fsid, '-')

print new_fsid

