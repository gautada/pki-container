#!/bin/sh

# Simple script to poll a file in the ca.vault that has the last accessed timestamp. If the file has not been updated 
# within the coded timeout period then unmount the volume.
VAULT=$1
echo "Cleanup vault: $VAULT"
LAST_FILE=/opt/docker/pki/vaults/$VAULT.vault/.last
echo "File:$LAST_FILE"
TIMEOUT=$(((5 * 60)))
echo "Timeout:$TIMEOUT"
if [ -f "$LAST_FILE" ] ; then
    LAST_TIMESTAMP=$(cat "$LAST_FILE")
    CURRENT_TIMESTAMP=$(date +%s)
    echo "Current:$CURRENT_TIMESTAMP - Last:$LAST_TIMESTAMP"
    DELTA_TIMESTAMP=$((($CURRENT_TIMESTAMP - $LAST_TIMESTAMP)))
    echo "Delta:$DELTA_TIMESTAMP"
    if  [ 1 = $((($DELTA_TIMESTAMP > $TIMEOUT))) ] ; then
        echo "Vault '$VAULT' will be unmounted"
        /home/mada/Development/Scripts/umount-vault $VAULT        
    else
        echo "Vault '$VAULT' timeout has not been reached"
    fi
else
    echo "Vault '$VAULT' is not mounted"
fi