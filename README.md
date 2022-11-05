# pki
<<<<<<< HEAD

This is an implementation of public key infrastructure implementation of a certificate authority (CA) for servers. This implementation uses an encrypted virtual disk to hold all of the secure bits.  Eventually, this should have a web front end for the public bits and overall management of the PKI. Currently, this is a series of scripts that allow for the manipulation of the CA in the encrypted disk.

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
dd if=/dev/urandom of=/opt/pki/ca.vhd bs=1M count=20
```

Encrypt the vhd to make Encrypted Virtual Hard Disk (evhd)
```
sudo cryptsetup -y luksFormat /home/pki/ca.vhd
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
sudo cryptsetup luksOpen /home/pki/ca.vhd ca.evhd
```

Validate the the encrypted vhd was opened and is an available device via
```
ls -l /dev/mapper/test.evhd
```

Or

```
sudo cryptsetup -v status your_mapping_name
```

Format the new device created by opening the encrypted vhd
```
sudo mkfs.ext4 /dev/mapper/encryptedVolume
```

Mount the device
```
sudo mount /dev/mapper/encryptedVolume /mnt/encryptedVolume
```

Check that everything works
```
df -h
```

Change the owner of the files
```
sudo chown mada /mnt/encryptedVolume
```

Unmount the device
```
sudo umount /mnt/encryptedVolume
```

Close the encrypted device
```
sudo cryptsetup luksClose encryptedVolume
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

