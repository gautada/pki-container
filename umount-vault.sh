#!/bin/sh

# Simple script to unmount the pki vaults
VAULT=$1
if [ -f "/opt/docker/pki/vaults/$VAULT.vault/.last" ] ; then
    sudo umount /opt/docker/pki/vaults/$VAULT.vault
    sudo cryptsetup luksClose /dev/mapper/$VAULT.crypt
else
    echo "Vault '$VAULT' is not mounted"
fi
 