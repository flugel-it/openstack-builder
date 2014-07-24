#!/bin/bash

# root@ubuntu:~# ip a s dev eth0 | grep link\/eth | awk '{print $2}' | awk -F\: '{print $4$5$6}'
# 00a41b
#
# root@ubuntu:~# printf "10.%d.%d.%d\n" 0x00 0xa4 0x1b
# 10.0.164.27

# root@ubuntu:~# echo ${STRING:0:2}
# 00
# root@ubuntu:~# echo ${STRING:2:2}
# a4
# root@ubuntu:~# echo ${STRING:4:4}
# 1b


MAC=$(ip a s dev eth0 | grep link\/eth | awk '{print $2}' | awk -F\: '{print $4$5$6}')
NEWHOSTNAME=$MAC.cheff.akilion.biz
NEWADDRESS=`printf "10.%d.%d.%d\n" 0x${MAC:0:2} 0x${MAC:2:2} 0x${MAC:4:4}`

echo $NEWADDRESS

if ! [ "${NEWHOSTNAME}" == `cat /etc/hostname` ]
then
   echo ${NEWHOSTNAME} > /etc/hostname

   echo "New hostname: ${NEWHOSTNAME}"
   echo "New Address: ${NEWADDRESS}/8"

   reboot
fi

