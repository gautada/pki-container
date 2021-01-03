# pki Service

This is a docker container that works as certificated authority for all of services as web servers, ssh keys, etc. The idea 
is to use an ecrypted virtual disk to hold all of the secure bits; (eventually) have a webserver that publishes all of the public bits; 
an api/function/app that makes management easy and mostly pre-configured in the docker service setup. 

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

Build Intermediate CA

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

