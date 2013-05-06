#!/bin/bash

killall -9 java

touch /tmp/prod_launch.log
echo "" > /tmp/prod_launch.log
echo "" > /opt/geograph/nohup.out


MYIP=$(/sbin/ifconfig eth0 | grep "inet " | awk -F: '{print $1}'| awk '{print $2}')
echo "my addresss" $MYIP


sed -i".bak" '/madmass-node/d' /etc/hosts
echo "$MYIP madmass-node" >> /etc/hosts

echo "current ip set" >> /tmp/prod_launch.log

cd /opt/geograph
echo "in /opt/geograh" >> /tmp/prod_launch.log

echo "" > $JBOSS_HOME/standalone/log/server.log
echo "" > $JBOSS_HOME/standalone/log/boot.log

rm -rf ${JBOSS_HOME}/standalone/tmp/*
rm -rf ${JBOSS_HOME}/standalone/data/*
rm -rf ${JBOSS_HOME}/standalone/deployments/*
echo "" >  log/development.log
echo "" >  log/production.log

torquebox deploy --env=production


nohup torquebox run --clustered --bind-address $MYIP --jvm-options -Djboss.bind.address.management=$MYIP &

cd  ../geograph-agent-farm
echo "" >  log/development.log
echo "" >  log/production.log

sleep 20

torquebox deploy --context-path=/farm --env=production

cd ../wpm

./run_cons_prod.sh

