# docker-swarm-nrpe

Simple bash script to monitor docker swarm using nrpe and nagios.

## Installation
Copy the script to /usr/local/bin/monitor_swarm.sh
chmod oug+rx /usr/local/bin/monitor_swarm.sh

Something along the line of creating a sudo file to be able to run it.
echo "nagios ALL = (root) NOPASSWD: /usr/local/bin/monitor_swarm.sh" > /etc/sudoers.d/check_swarm

Put the script in your nrpe config by creating something like /etc/nagios/nrpe.d/check_swarm.cfg with:
command[check_swarm]=sudo /usr/local/bin/monitor_swarm.sh
