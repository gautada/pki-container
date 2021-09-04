ARG ALPINE_TAG=3.14.1
FROM alpine:$ALPINE_TAG as config-alpine

RUN apk add --no-cache tzdata

RUN cp -v /usr/share/zoneinfo/America/New_York /etc/localtime
RUN echo "America/New_York" > /etc/timezone

FROM alpine:$ALPINE_TAG

RUN apk add --no-cache e2fsprogs easypki cryptsetup git openssl sudo shadow nano

COPY pki-setup /usr/bin/pki-setup

COPY vault-setup /usr/bin/vault-setup
COPY vault-mount /usr/bin/vault-mount
COPY vault-umount /usr/bin/vault-umount

COPY ca-setup /usr/bin/ca-setup
COPY ca-refresh /usr/bin/ca-refresh
COPY ca-server /usr/bin/ca-server
COPY ca-client /usr/bin/ca-client
COPY ca-revoke /usr/bin/ca-revoke

COPY vault-monitor /usr/bin/vault-monitor

COPY profile /home/pki/.profile
COPY logout /home/pki/.logout

ARG USER=pki
RUN addgroup $USER \
 && adduser -D -s /bin/sh -G $USER $USER \
 && echo "$USER:$USER" | chpasswd

RUN echo "%wheel         ALL = (ALL) NOPASSWD: /usr/sbin/crond,/bin/mount,/bin/umount,/sbin/cryptsetup,/sbin/mkfs.ext4,/bin/chown,/bin/chmod,/bin/mkdir" >> /etc/sudoers \
 && usermod -aG wheel $USER
 

USER $USER

# ln -s /usr/bin/vault-monitor /etc/periodic/15min/00-vault-monitor 
# /usr/bin/vault-monitor
# RUN touch /var/lib/pki/one.evd && touch touch /var/lib/pki/two.evd
#  && echo "date +%s > /opt/docker/pki/vaults/root/.last" > /root/.ash_history \
#  && echo "date +%s > /opt/docker/pki/vaults/ca.gautier.org/.last" > /root/.ash_history 
# && chmod u+s /bin/busybox
#
# USER pki
#
# RUN git config --global user.email "pki@gautier.org" \
#  && git config --global user.name "PKI Vault" \
#  && git config --global credential.helper store

WORKDIR /home/pki


# ENTRYPOINT ["/usr/bin/sudo", "/usr/sbin/crond", "-f"]




