#!/bin/ash


# kubectl create secret tls test-tls --key="tls.key" --cert="tls.crt"
NAMESPACE=$1
FQDN=$2
/usr/bin/kubectl create secret -n $NAMESPACE tls tls-$FQDN --key="/mnt/vault/servers/gautier.org/live/$FQDN/privkey.pem" --cert="/mnt/vault/servers/gautier.org/live/$FQDN/cert.pem"
