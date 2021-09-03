FROM alpine:3.12.1 as config-alpine

RUN apk add --no-cache tzdata

RUN cp -v /usr/share/zoneinfo/America/New_York /etc/localtime
RUN echo "America/New_York" > /etc/timezone

FROM alpine:3.12.1

# VOLUME ["/opt/pki-data"]

RUN apk add --no-cache e2fsprogs easypki cryptsetup git openssl sudo shadow nano
# busybox-suid
# parted lvm2

ENV PKI_ROOT=/home/pki/root
ENV PKI_ORGANIZATION="Adam Gautier"
ENV PKI_ORGANIZATIONAL_UNIT=Personal
ENV PKI_COUNTRY=US
ENV PKI_LOCALITY=Charlotte
ENV PKI_PROVINCE="North Carolina"

# COPY ca-setup /usr/bin/ca-setup
COPY ca-refresh /usr/bin/ca-refresh
COPY ca-server /usr/bin/ca-server
COPY ca-client /usr/bin/ca-client
COPY ca-revoke /usr/bin/ca-revoke
COPY vault-mount /usr/bin/vault-mount
COPY vault-umount /usr/bin/vault-umount
COPY vault-monitor /usr/bin/vault-monitor

COPY profile /home/pki/.profile
COPY logout /home/pki/.logout

# Use comma (,) to seperate commands in wheel
# http://www.softpanorama.org/Access_control/Sudo/sudoer_file_examples.shtml
RUN echo "%wheel         ALL = (ALL) NOPASSWD: /usr/sbin/crond,/bin/mount,/bin/umount,/sbin/cryptsetup,/sbin/mkfs.ext4,/bin/chown,/bin/chmod" >> /etc/sudoers \
 && adduser -D -s /bin/sh pki \
 && echo 'pki:pki' | chpasswd \
 && usermod -aG wheel pki \
 && mkdir -p /mnt/pki/root \
 && chown -R pki:pki /mnt/pki \
 && ln -s /mnt/pki/root /home/pki/root \
 && chown -R pki:pki /home/pki \
 && ln -s /usr/bin/vault-monitor /etc/periodic/15min/00-vault-monitor 

# /usr/bin/vault-monitor
  

# RUN touch /var/lib/pki/one.evd && touch touch /var/lib/pki/two.evd
#  && echo "date +%s > /opt/docker/pki/vaults/root/.last" > /root/.ash_history \
#  && echo "date +%s > /opt/docker/pki/vaults/ca.gautier.org/.last" > /root/.ash_history 
# && chmod u+s /bin/busybox

USER pki

RUN git config --global user.email "pki@gautier.org" \
 && git config --global user.name "PKI Vault" \
 && git config --global credential.helper store

WORKDIR /home/pki

ENTRYPOINT ["/usr/bin/sudo", "/usr/sbin/crond", "-f"]




