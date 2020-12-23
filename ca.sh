#/bin/sh
VAULT=/opt/docker/pki/vaults/ca.vault
LAST_FILE=$VAULT/.last
if  [ -f $LAST_FILE ] ; then
    export PKI_ROOT=$VAULT
    export PKI_ORGANIZATION="Adam Gautier"
    export PKI_ORGANIZATIONAL_UNIT="Personal"
    export PKI_COUNTRY="US"
    export PKI_LOCALITY="Charlotte"
    export PKI_PROVINCE="North Carolina"

    date +%s > $LAST_FILE
    easypki "$@"
else
    echo "Vault 'ca' is not mounted on the host"
fi