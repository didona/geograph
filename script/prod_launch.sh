#!/bin/bash


killall -9 java
MYIP=$(/sbin/ifconfig eth0 | grep "inet " | awk -F: '{print $1}'| awk '{print $2}')
echo "my addresss" $MYIP

sed -i".bak" '/madmass-node/d' /etc/hosts
echo "$MYIP madmass-node" >> /etc/hosts


torquebox run --clustered --bind-address $MYIP