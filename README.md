# PKI

## Abstract

This container is a a secure public key infrastructure (PKI) implementation of a certificate authority. The purpose of this implementation is to provide a mechanism for clients to use certificate authentication and server transport layer security (TLS) encryption using [Let's Encrypt](https://letsencrypt.org).

This implementation uses an [encrypted virtual disk](https://gitlab.com/cryptsetup/cryptsetup) to hold all of the secure bits. 

Generally, this container is a collection of scripts that are used for managing the PKI/CA.  

### Client

Following [Client-Side Certificate Authentication with NGINX](https://fardog.io/blog/2017/12/30/client-side-certificate-authentication-with-nginx/) the script `pki-create-client [host.domain.tld]` exports a password protected `.pfx` file for distribution.

### Server

Using [certbot](https://certbot.eff.org) the script `pki-create-server [domain.tld]` generates a signed certificate/key pair for the entire domain (i.e. *.domain.tld).  The authorization/verification hook is via DNS and a specific script `hover-auth-hook.py` provides the mechanism to update a domain on [hover](https://www.hover.com). The certificate/key pair is exported as a password protects `.pfx` for distribution.

## Features

### Secure Vault

All data is stored in virtual hard disks(vhd) files. Once created these files are encrypted, then formatted and mounted. The instructions used were from "[How to Set Up Virtual Disk Encryption on GNU/Linux that Unlocks at Boot](https://leewc.com/articles/how-to-set-up-virtual-disk-encryption-linux/)". 

### Export Feature

A PKCS#12 or .pfx file is a file which contains both private key and X.509 certificate, ready to be installed by the customer into servers such as IIS, Tomkat or Exchange. The script `pki-export` produces a password protected `.pfx` file to `/opt/pki/outbox`.

### Scripts

Scripts are divided into three main segments:

#### Vault
 
- **vault-setup**: `/home/pki/setup-vault` creates the secure vault with an encrypted virtual hard disk (evhd) and makes sure the device can be mounted.  After infrastructure setup this script creates the CA for clients in the vault unmounts the vault to leave it in a secure state.  
- **vault-mount**: Mounts an existing evhd vault to /mnt/vault
- **vault-umount**: Unmounts the vault and closes the device leaving the vault in as a secure a state as possible.
- **vault-refresh**: Update the /mnt/vault/.last file with a epoch timestamp. This only works if the vault is mounted. This timestamp is used as the keep-alive ticker.
- **vault-monitor**: Script that runs every 15min using `crond`. This script tests the keep-alive ticker and will default to calling `vault-umount`.

#### Client

- **pki-create-client**: `pki-create-client [host.domain.tld]` will create a `.pfx` package that holds the cert/key for a specific host. Just follow the propmpts for the appropriate passwords as asked.

#### Server

- **certbot-upgrade**: Makes sure certbot is fully upgraded.  This runs automatically via `crond` monthly.
- **hover-auth-hook**: Updates the `_acme-challenge` TXT field for the domain hosted on [hover](https://www.hover.com). This requires the environment variables `HOVER_USERNAME` and `HOVER_PASSWORD` to authenticate.
- **pki-create-server**: `pki-create-server [domain.tld]` will produce a cert/key pair for all hosts in the domain. This script wraps the `certbot` script and exports the cert/key pairs for distribution and if configured installed as a [kubernetes secret](https://kubernetes.io/docs/concepts/configuration/secret/).

#### Marked for Removal

The following scripts are legacy and no longer used but these are maintained for future reference as needed.

##### let's encrypt

- **certbot-wrapper**: Executes `certbot` limited to the specifics of how we use for `*.domain.tld`. This script creates a signed cert/key for HTTPS server that works out of the box.

##### easypki

These were part of trying to use [easypki](https://github.com/google/easypki) as the PKI/CA management API.  Could not get the cert/key pairs to work properly. 

- **vault-domain-setup**: Creates the CA for a specific domain.
- **ca-client**: Uses easypki to create client cert/key.
- **ca-server**: Uses easypki to create a server cert/key that is not signed, so does not work out of the box in browsers.
- **ca-revoke**: Creates a revokation list 
- pki-export: Originally ment to export cert/key pairs to pfx.

## Development

- Error with 10M container "https://superuser.com/questions/1557750/why-does-cryptsetup-fail-with-container-10m-in-size"
- Reference: https://wiki.alpinelinux.org/wiki/LVM_on_LUKS
- [Manpage](https://www.man7.org/linux/man-pages/man8/cryptsetup.8.html)

## Testing

- Interactive testing guide:  The scripts are prone to bugs during development and to save time in development should be directly symlinked to scripts from repository.

## Implementation 

### Container/Kubernetes

- To run in a container the `--privileged` flag must be used because the encryption uses a loopback device.
