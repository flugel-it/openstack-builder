#!/bin/bash

cd /var/backups/dws &&
mongodump -o mongodump &&
tar cfz mongodump.tgz mongodump &&
rm -fR mongodump &&
exit 0

exit 1

