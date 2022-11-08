# PKI

## Abstract

This is an implementation of public key infrastructure (PKI) implementation of a certificate authority (CA) for private/personal servers. This implementation uses an [encrypted virtual disk](https://gitlab.com/cryptsetup/cryptsetup) to hold all of the secure bits. Currently, this is a series of scripts, based on [easypki](https://github.com/google/easypki) that allow for the manipulation of the CA in the encrypted disk. Eventually, this should have a web front end for the public bits and overall management of the PKI. Additionally, this container contains the [certbot](https://certbot.eff.org) which provides certificates to be used publicly.

This container provides a private certificate authority(CA) through Google's 'public key infrastructure API - [easyPKI](https://github.com/google/easypki) that intends to provide most of the components needed to manage a PKI, so you can either use the API in your automation, or use the CLI. When public facing keys are needed (i.e. website certificates that need to be signed by a trusted cpublic ertificate authority) the [Automatic Certificate Management Environment (ACME)](https://datatracker.ietf.org/doc/html/rfc8555) provides integration service with [certbot](https://certbot.eff.org) connecting to [Let's Encrypt](https://letsencrypt.org). 

This container is mainly a collection of scripts that move to automate the CA/PKI management. The CLI can be accessed from a web terminal interface.


## Features

### Secure Vault

All data is stored in virtual hard disks(vhd) files. Once created these files are encrypted, then formatted and mounted. The instructions used were from "[How to Set Up Virtual Disk Encryption on GNU/Linux that Unlocks at Boot](https://leewc.com/articles/how-to-set-up-virtual-disk-encryption-linux/)". To run in a container the `--privileged` flag must be used because the encryption uses a loopback device.

### Export Feature

A PKCS#12 or .pfx file is a file which contains both private key and X.509 certificate, ready to be installed by the customer into servers such as IIS, Tomkat or Exchange. The script `pki-export` produces a password protected `.pfx` file to `/opt/pki/outbox`.
### Scripts

Scripts are divided into three main segments:

#### Vault
 
- **vault-setup**: Creates the certificate authority(CA) in an encrypted virtual hard disk (evhd) and makes sure the device can be mounted.  After infrastructure setup this script creates the root CA in the vault unmounts the vault to leave it in a secure state.  
- **vault-mount**: Mounts an existing evhd vault to /mnt/vault
- **vault-umount**: Unmounts the vault and closes the device leaving the vault in as a secure a state as possible.
- **vault-refresh**: Update the /mnt/vault/.last file with a epoch timestamp. This only works if the vault is mounted. This timestamp is used as the keep-alive ticker.
- **vault-monitor**: Script that runs every 15min using `crond`. This script tests the keep-alive ticker and will default to calling `vault-umount`.

#### CA/PKI

- **domain-setup**: Creates and intermediate CA for a specific domain.
- **ca-client**:
- **ca-server**:
- **ca-revoke**:
- **export-pki**

#### Public PKI

- **certbot-wrapper**:
- **certbot-upgrade**:
- **auth-hook**:
- **hover-auth-hook**:



 kubectl create secret generic ca-secret --from-file=tls.crt=server.crt --from-file=tls.key=server.key --from-file=ca.crt=ca.crt
 
```
    @startuml
    !include <C4/C4.puml>
    !include <C4/C4_Context.puml>
    !include <C4/C4_Container.puml>
    !include <C4/C4_Component.puml>
    !include <C4/C4_Dynamic.puml>
    !include <C4/C4_Deployment.puml>

    ' Boundary(alias, label, ?type, ?tags, $link)
    ' Enterprise_Boundary(alias, label, ?tags, $link)
    ' System_Boundary

    ' Person{_Ext}(alias, label, ?descr, ?sprite, ?tags, $link)
    ' System(alias, label, ?descr, ?sprite, ?tags, $link)

    ' Component{Db|Queue_Ext}(alias, label, ?techn, ?descr, ?sprite, ?tags, ?link)

    Title PKI Container - Component Diagram

    Boundary("DEVICE", "Anonymously Authenticated Device", "Laptop/Mobile Device") {
     Person("USER", "Non-Authenticate User")
     Component("CCERT", "Client Authetication Certificate", "certificate", "Client Authetication Certificate")
    }
    Boundary("PKI", "pki-container", "Container") {
     Component("EPKI", "easypki", "API", "easyPKI scripts and API")
     Boundary("MNT", "/mnt/ca", "Mountpoint") {
      ComponentDb("CA", "Root CA", "ca", "Root Certificate Authority")
      ComponentDb("DCA", "Domain CA", "ca.domain.fqdn", "Domain Certificate Authority")
      ComponentDb("EVHD", "evhd", "/opt/pki/ca.evhd", "Encrypted(luks2) Virtual Hard Drive(evhd)")
     }
     Component("WTTY", "ettty", "TTY(Web)", "Web based TTY Interface")
    }

    Rel("EPKI", "CA", "Manage Keys")
    Rel("EPKI", "DCA", "Manage Keys")
    Rel("CA", "EVHD", "Store Keys")
    Rel("DCA", "EVHD", "Store Keys")
    Rel("USER", "WTTY", "Accesses")
    Rel("WTTY", "EPKI", "Uses")
    Rel("PKI", "CCERT", "Authenticates")
    @enduml
```


Must be privileged --privilaged

Notes: 

Error with 10M container "https://superuser.com/questions/1557750/why-does-cryptsetup-fail-with-container-10m-in-size"
Reference: https://wiki.alpinelinux.org/wiki/LVM_on_LUKS

https://www.tutorialspoint.com/unix_commands/cryptsetup.htm


- - - - - - - - - -

