# pki

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

## Secure Vaults

All data is stored in virtual hard disks(vhd) files.  Once created these files are encrypted, then formatted and mounted. The instructions used 
were from ["How to Set Up Virtual Disk Encryption on GNU/Linux that Unlocks at Boot"(https://leewc.com/articles/how-to-set-up-virtual-disk-encryption-linux/)].

Create vhd file
```
dd if=/dev/urandom of=/pathtoNew/mySecretDisk bs=1M count=10
```

Encrypt the vhd
```
sudo cryptsetup -y luksFormat ~/mySecretDisk
```

Open the encrypted vhd
```
sudo cryptsetup luksOpen ~/mySecretDisk your_mapping_name
```

Validate the the encrypted vhd was opened and is an available device via
```
ls -l /dev/mapper/your_mapping_name
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


 
## Certificate Authority

The Ccertificate authoprity (CA) is setup and managed via [easypki(https://github.com/google/easypki/blob/master/README.md)].

Build CA

```
easypki --root ~/certificates create --filename root --ca "Adam Thomas Gautier Personal Certificate Authority"
mv ~/ca/root/keys/*.key /mnt/root.kvlt/
```

Build Intermediate CA

```
easypki --root ~/certificates create --ca-name root --filename ca.gautier.local --intermediate "Certificate Authority for ca.gautier.local"
mv ~/ca/ca.gautier.local/keys/*.key /mnt/ca.gautier.local.kvlt/
```

Server Certificate



Client Certificate

Install Server Cert

key => Server
cert + intermediate => Server

Client Cert
ca bundle
cert + key = cert


Docker needs to be --privilaged

Notes: 

Error with 10M container "https://superuser.com/questions/1557750/why-does-cryptsetup-fail-with-container-10m-in-size"
Reference: https://wiki.alpinelinux.org/wiki/LVM_on_LUKS

