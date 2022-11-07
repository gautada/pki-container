# PKI

## Abstract

This is an implementation of Google's 'public key infrastructure API - [easyPKI](https://github.com/google/easypki) that intends to provide most of the components needed to manage a PKI, so you can either use the API in your automation, or use the CLI. The CLI can be accessed from as simple web terminal interface. This provides a private certificate authority. For public facing keys (i.e. Website certificates) the [Automatic Certificate Management Environment (ACME)](https://datatracker.ietf.org/doc/html/rfc8555) provides integration service with [certbot](https://certbot.eff.org) connecting to [Let's Encrypt](https://letsencrypt.org).

Currently this container is mainly a set of scripts for administering the PKI/CA systems:

- **pki-setup**: Creates the CA encrypted virtual hard disk (evhd) and makes sure the device is mounted.
- **vault-setup**: Creates the **easypki** vaults for root and a domain (ca.domain.fqdn). 
- **vault-mount**

https://github.com/certbot/certbot


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

## Container

### Versions

This is a specific configuration of existing components and versioning is maintained through...

### Manual

#### Build
```
docker build --build-arg ALPINE_TAG=3.14.1 --file Containerfile --tag pki.dev .
```

#### Run

To support encrypted virtual disks the container must use the `--privileged` flag.

```
docker run -i -t --privileged --name pki --rm pki:dev /bin/sh
```
=======


openssl req -new -x509 -days 365 -key /mnt/ca/ca.gautier.org/keys/ca.gautier.org.key -out ca.gautier.org.crt 

This is an implementation of public key infrastructure (PKI) implementation of a certificate authority (CA) for private/personal servers. This implementation uses an [encrypted virtual disk](https://gitlab.com/cryptsetup/cryptsetup) to hold all of the secure bits. Currently, this is a series of scripts, based on [easypki](https://github.com/google/easypki) that allow for the manipulation of the CA in the encrypted disk. Eventually, this should have a web front end for the public bits and overall management of the PKI. Additionally, this container contains the [certbot](https://certbot.eff.org) which provides certificates to be used publicly.

## Container

### Versions

This is a specific configuration of existing components versioning should be mapped.

crypsetup 
easypki v1.1.0
certbot v1.19.0


### Manual

#### Build
```
docker build --build-arg ALPINE_TAG=3.14.1 --file Containerfile --tag pki.dev .
```

#### Run

To support encrypted virtual disks the container must use the `--privileged` flag.

```
docker run -i -t --privileged --name pki --rm pki:dev /bin/sh
```


>>>>>>> dev

## Secure Vaults

All data is stored in virtual hard disks(vhd) files.  Once created these files are encrypted, then formatted and mounted. The instructions used 
were from ["How to Set Up Virtual Disk Encryption on GNU/Linux that Unlocks at Boot"(https://leewc.com/articles/how-to-set-up-virtual-disk-encryption-linux/)].

Create the Virtual Hard Disk (vhd)
```
dd if=/dev/urandom of=/opt/pki/$VAULT.vhd bs=1M count=100    
```

Encrypt the vhd to make Encrypted Virtual Hard Disk (evhd)
```
sudo cryptsetup --type=luks2 --verify-passphrase luksFormat /opt/pki/ca.evhd
```
Response: Now you need to encrypt the vhd and provide the passphrase
```
WARNING!
========
This will overwrite data on /home/pki/test.vhd irrevocably.

Are you sure? (Type 'yes' in capital letters): YES
Enter passphrase for /home/pki/test.vhd: 
Verify passphrase: 
```

`
Open the encrypted vhd
```
sudo cryptsetup luksOpen /opt/pki/ca.evhd ca.vhd
```

Validate the the encrypted vhd was opened and is an available device via
```
ls -l /dev/mapper/ca.vhd
```

Or

```
sudo cryptsetup --verbose status ca.vhd
```

Format the new device created by opening the encrypted vhd
```
sudo mkfs.ext4 /dev/mapper/ca.vhd
```

Mount the device
```
sudo mount /dev/mapper/ca.vhd /mnt/ca
```

Check that everything works
```
df -h
```

Change the owner of the files
```
sudo chown -R pki:pki /mnt/ca
```

Unmount the device
```
sudo umount /mnt/ca
```

Close the encrypted device
```
sudo cryptsetup luksClose ca.vhd
```


 
key => Server
cert + intermediate => Server

Client Cert
ca bundle
cert + key = cert


Docker needs to be --privilaged

Notes: 

Error with 10M container "https://superuser.com/questions/1557750/why-does-cryptsetup-fail-with-container-10m-in-size"
Reference: https://wiki.alpinelinux.org/wiki/LVM_on_LUKS

https://www.tutorialspoint.com/unix_commands/cryptsetup.htm


- - - - - - - - - -

