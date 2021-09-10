ARG ALPINE_TAG=3.14.1
FROM alpine:$ALPINE_TAG as config-alpine

RUN apk add --no-cache tzdata

RUN cp -v /usr/share/zoneinfo/America/New_York /etc/localtime
RUN echo "America/New_York" > /etc/timezone

FROM alpine:$ALPINE_TAG

COPY --from=config-alpine /etc/localtime /etc/localtime
COPY --from=config-alpine /etc/timezone  /etc/timezone

# - - - - - - - - - - - -  CERTBOT - - - - - - - - -
RUN apk add --no-cache --update build-base python3 py3-augeas py3-cryptography py3-pip
RUN pip install --upgrade pip \
 && pip install certbot \
 && mkdir -p /var/log/letsencrypt /var/lib/letsencrypt

COPY hover-auth-hook.py /usr/bin/hover-auth-hook
COPY certbot-wrapper /usr/bin/certbot-wrapper
# - - - - - - - - - - PKI - - - - - - - - -
RUN apk add --no-cache e2fsprogs easypki cryptsetup git openssl sudo shadow nano

COPY pki-setup /usr/bin/pki-setup

COPY vault-setup /usr/bin/vault-setup
COPY vault-mount /usr/bin/vault-mount
COPY vault-umount /usr/bin/vault-umount
COPY vault-refresh /usr/bin/vault-refresh

COPY ca-server /usr/bin/ca-server
COPY ca-client /usr/bin/ca-client
COPY ca-revoke /usr/bin/ca-revoke

COPY vault-monitor /etc/periodic/15min/vault-monitor

ARG USER=pki
RUN addgroup $USER \
 && adduser -D -s /bin/sh -G $USER $USER \
 && echo "$USER:$USER" | chpasswd

RUN echo "%wheel         ALL = (ALL) NOPASSWD: /usr/sbin/crond,/bin/mount,/bin/umount,/sbin/cryptsetup,/sbin/mkfs.ext4,/bin/chown,/bin/chmod,/bin/mkdir" >> /etc/sudoers \
 && usermod -aG wheel $USER \
 && chown pki:pki -R /var/log/letsencrypt /var/lib/letsencrypt
 
USER $USER

WORKDIR /home/pki

ENTRYPOINT ["/usr/bin/sudo", "/usr/sbin/crond", "-f", "-l", "0"]
