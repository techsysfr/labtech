#!/bin/bash

pulpAdminPassword=$(grep ^default_password /etc/pulp/server.conf | cut -d' ' -f2)

STATE=""
for TASK in `pulp-admin -u admin -p $pulpAdminPassword tasks list | egrep '^Task Id:|^State:' | sed -e 's,^Task Id: ,,' -e 's,^State: ,,'`; do
    if [ "$STATE" = "" ]; then
        STATE=$TASK
    else
        if [ $STATE != Successful ] && [ $STATE != Cancelled ] && [ $STATE != Failed ]; then
            pulp-admin -u admin -p $pulpAdminPassword tasks details --task-id=$TASK
            pulp-admin -u admin -p $pulpAdminPassword tasks cancel --task-id=$TASK
        fi
    STATE=""
    fi
done
