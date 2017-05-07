#! /bin/bash

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin

ISMANAGER=$(docker info -f "{{.Swarm.ControlAvailable}}")

if [ "x${ISMANAGER}" == "xtrue" ]
then
    # i am a manager
    MYSTATE=$(docker node inspect self --format "{{ .Status.State }}")
    if [ "x${MYSTATE}" != 'xready' ]
    then
    	echo "CRITICAL: My state is ${MYSTATE} (not ready)"
    exit 2
    fi

    HASLEADER=0
    for node in $(docker node ls | cut -c30- | sed -e '1d' -e 's/^ //' -e 's/ .*//')
    do
    	NODESTATUS=$(docker node inspect "${node}" --format "{{ .Status.State }}")
    	if [ "x${NODESTATUS}" != 'xready' ]
    	then
    		echo "CRITICAL: $node is not ready"
    		exit 2
   		fi

    	MANAGERSTATUS=$(docker node inspect "${node}" --format "{{ .ManagerStatus }}")
    	if [ "x${MANAGERSTATUS}" != "x<nil>" ]
    	then
    		# We are a manager
			if echo "${MANAGERSTATUS}" | grep true > /dev/null 2>&1
			then
					HASLEADER=1
			fi
			if ! echo "${MANAGERSTATUS}" | grep reachable > /dev/null 2>&1
			then
				echo "CRITICAL: $node is not a reachable manager"
				exit 2
			fi
		fi
    done

    if [ $HASLEADER -eq 0 ]
    then
    	echo "CRITICAL: Swarm cluster has no leader"
    	exit 2
    fi

    echo "OK: I am a happy manager"                 
    exit 0
else
    # i am not a manager
    echo "OK: I am not a manager"
    exit 0
fi

