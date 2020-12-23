#!/bin/sh

# This is a script to mount the encrypted ca.vhd making it available to the pki docker container.
VAULT=$1
PKI_PATH="/home/mada/Development/Configuration/pki"
VHD_FILE="$PKI_PATH/disks/$VAULT.vhd"
VAULT_PATH="$PKI_PATH/vaults/$VAULT"
echo $VAULT_PATH
if [ -f $VHD_FILE ] ; then
    if [ -f "$VAULT_PATH/.last" ] ; then
        echo "Vault '$VAULT' is already mounted"
    else
        sudo cryptsetup luksOpen "$VHD_FILE" "$VAULT.crypt"
        sudo mount "/dev/mapper/$VAULT.crypt" "$VAULT_PATH"
        date +%s > "$VAULT_PATH/.last"
    fi
else
   echo "Cannot find the virtual hard drive (vhd) file for vault '$VAULT' to mount"
fi
