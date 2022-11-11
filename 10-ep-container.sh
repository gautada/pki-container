#!/bin/ash
#
# This is entrypoint should launch the container service when a command is not
# provided in an `exec` script.
#
# This is the script for the wetty interface which proivides a cli via a web browser.

WETTY_USER="$(/usr/bin/whoami)"
WETTY_TITLE="PKI Client"
WETTY_COMMAND="/bin/ash"
# "/usr/bin/ansible-console"
# "/bin/ash"

echo "---------- [ WETTY INTERFACE($WETTY_USER) ] ----------"

# Make the server ssh key on start
if [ ! -f "/etc/ssh/ssh_host_rsa_key" ] ; then
 /usr/bin/sudo /usr/bin/ssh-keygen -A -t rsa -N ''
fi
# Launch the ssh daemon
/usr/bin/sudo /usr/sbin/sshd
# Setup the local ssh keys
if [ ! -f /home/$WETTY_USER/.ssh/id_rsa ] ; then
 /bin/mkdir /home/$WETTY_USER/.ssh
 /bin/chmod 700 /home/$WETTY_USER/.ssh
 /usr/bin/ssh-keygen -t rsa -N '' -f /home/$WETTY_USER/.ssh/id_rsa
 /bin/cp /home/$WETTY_USER/.ssh/id_rsa.pub /home/$WETTY_USER/.ssh/authorized_keys
 /bin/chmod 600 /home/$WETTY_USER/.ssh/authorized_keys
fi
# Launch the wetty interface
if [ -z "$ENTRYPOINT_PARAMS" ] ; then
 /home/$WETTY_USER/.yarn/bin/wetty --base / --port 8080 --ssh-host localhost --ssh-user $WETTY_USER --ssh-auth publickey --ssh-key /home/$WETTY_USER/.ssh/id_rsa --force-ssh --title $WETTY_TITLE --command $WETTY_COMMAND
 fi
return 0

# RETURN_VALUE=0
# echo "---------- [ ACME(certbot) -- FOREGROUND crond ] ----------"
# if [ -z "$ENTRYPOINT_PARAMS" ] ; then
#    TEST="$(/usr/bin/pgrep /usr/sbin/crond)"
#  if [ $? -eq 0 ] ; then
#    /usr/bin/sudo /usr/bin/killall crond
#  fi
#  /usr/bin/sudo /usr/sbin/crond -f -l 8
#  unset TEST
# fi
# unset ENTRYPOINT_PARAM
# return $RETURN_VALUE
