ARG ALPINE_VERSION=3.16.2

FROM gautada/alpine:$ALPINE_VERSION

# ╭――――――――――――――――――――╮
# │ METADATA          │
# ╰――――――――――――――――――――╯
LABEL source="https://github.com/gautada/pki-container.git"
LABEL maintainer="Adam Gautier <adam@gautier.org>"
LABEL description="PKI container provides all of the requirements for maintaining a useful public-key infrastructure."

# ╭――――――――――――――――――――╮
# │ STANDARD CONFIG    │
# ╰――――――――――――――――――――╯

# USER:
ARG USER=pki

ARG UID=1001
ARG GID=1001
RUN /usr/sbin/addgroup -g $GID $USER \
 && /usr/sbin/adduser -D -G $USER -s /bin/ash -u $UID $USER \
 && /usr/sbin/usermod -aG wheel $USER \
 && /bin/echo "$USER:$USER" | chpasswd

# PRIVILEGE:
COPY wheel  /etc/container/wheel

# BACKUP:
COPY backup /etc/container/backup

# ENTRYPOINT:
RUN /bin/rm -v /etc/container/entrypoint
COPY entrypoint /etc/container/entrypoint

# FOLDERS
RUN /bin/chown -R $USER:$USER /mnt/volumes/container \
 && /bin/chown -R $USER:$USER /mnt/volumes/backup \
 && /bin/chown -R $USER:$USER /var/backup \
 && /bin/chown -R $USER:$USER /tmp/backup

# ╭――――――――――――――――――――╮
# │ APPLICATION        │
# ╰――――――――――――――――――――╯
ARG CRYPTSETUP_VERSION=2.4.3
ARG CRYPTSETUP_PACKAGE="$CRYPTSETUP_VERSION"-r0

RUN /sbin/apk add --no-cache build-base yarn npm git
RUN /sbin/apk add --no-cache cryptsetup=$CRYPTSETUP_PACKAGE
RUN /sbin/apk add --no-cache  e2fsprogs easypki openssh-client openssh openssl python3 py3-augeas py3-cryptography py3-pip
RUN /sbin/apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing kubectl

RUN /bin/ln -fsv /mnt/volumes/configmaps/letsencrypt /etc/container/letsencrypt \
 && /bin/ln -fsv /mnt/volumes/container/letsencrypt /mnt/volumes/configmaps/letsencrypt

RUN /bin/ln -fsv /mnt/volumes/configmaps/auth.env /etc/container/auth.env \
 && /bin/ln -fsv /mnt/volumes/container/auth.env /mnt/volumes/configmaps/auth.env

RUN /bin/ln -fsv /etc/container/kube.conf \
 && /bin/ln -fsv /mnt/volumes/configmaps/kube.conf /etc/container/kube.conf \
 && /bin/ln -fsv /mnt/volumes/container/kube.conf /mnt/volumes/configmaps/kube.conf

# COPY vault-domain-setup /usr/bin/vault-domain-setup
# COPY vault-setup /usr/bin/vault-setup
COPY vault-mount /usr/bin/vault-mount
COPY vault-umount /usr/bin/vault-umount
COPY vault-refresh /usr/bin/vault-refresh
COPY vault-monitor /usr/bin/vault-monitor
COPY pki-create-client /usr/bin/pki-create-client
COPY pki-create-server /usr/bin/pki-create-server
COPY setup-vault /home/pki/.pki/setup-vault
# COPY ca-server /usr/bin/ca-server
# COPY ca-client /usr/bin/ca-client
# COPY ca-revoke /usr/bin/ca-revoke
# COPY pki-export /usr/bin/pki-export
# COPY fqdn-parser /usr/bin/fqdn-parser

# RUN ln -s /opt/pki/scripts/vault-domain-setup /usr/bin/vault-domain-setup \
#  && ln -s /opt/pki/scripts/vault-setup /usr/bin/vault-setup \
#  && ln -s /opt/pki/scripts/vault-mount /usr/bin/vault-mount \
#  && ln -s /opt/pki/scripts/vault-umount /usr/bin/vault-umount \
#  && ln -s /opt/pki/scripts/vault-refresh /usr/bin/vault-refresh \
#  && ln -s /opt/pki/scripts/vault-monitor /usr/bin/vault-monitor \
#  && ln -s /opt/pki/scripts/ca-server /usr/bin/ca-server \
#  && ln -s /opt/pki/scripts/ca-client /usr/bin/ca-client \
#  && ln -s /opt/pki/scripts/ca-revoke /usr/bin/ca-revoke \
#  && ln -s /opt/pki/scripts/pki-export /usr/bin/pki-export \
#  && ln -s /opt/pki/scripts/fqdn-parser /usr/bin/fqdn-parser
 
RUN ln -s /usr/bin/vault-monitor /etc/periodic/15min/vault-monitor

# - - - CERTBOT - - -
RUN update-ca-certificates \
 && /bin/mkdir -p /mnt/vault /var/log/letsencrypt /var/lib/letsencrypt \
 && /usr/bin/pip install --upgrade pip \
 && /usr/bin/pip install certbot
 
COPY auth-hook /usr/bin/auth-hook
COPY hover-auth-hook.py /usr/bin/hover-auth-hook
COPY certbot-wrapper /usr/bin/certbot-wrapper
RUN ln -s /usr/bin/certbot-wrapper /etc/periodic/15min/certbot-wrapper
COPY certbot-upgrade /usr/bin/certbot-upgrade
RUN ln -s /usr/bin/certbot-upgrade /etc/periodic/monthly/certbot-upgrade

# RUN ln -s /opt/acme/auth.env /etc/container/configmap.d/auth.env

# ╭――――――――――――――――――――╮
# │ SUDO               │
# ╰――――――――――――――――――――╯
# COPY wheel-ssh /etc/container/wheel.d/wheel-ssh
# COPY wheel-pki /etc/container/wheel.d/wheel-pki
# COPY wheel-pip /etc/container/wheel.d/wheel-pip
# COPY wheel-tee /etc/container/wheel.d/wheel-tee
#
# ╭――――――――――――――――――――╮
# │ USER               │
# ╰――――――――――――――――――――╯
# ARG UID=1001
# ARG GID=1001
# ARG USER=pki
# VOLUME /opt/$USER
# RUN /bin/mkdir -p /opt/$USER \
#  && /usr/sbin/addgroup -g $GID $USER \
#  && /usr/sbin/adduser -D -G $USER -s /bin/ash -u $UID $USER \
#  && /usr/sbin/usermod -aG wheel $USER \
#  && /bin/echo "$USER:$USER" | chpasswd \
#  && /bin/chown $USER:$USER -R /opt/$USER
# USER $USER
# WORKDIR /home/$USER
#
# ╭――――――――――――――――――――╮
# │ PORTS              │
# ╰――――――――――――――――――――╯
# EXPOSE 8080
#
# ln -s /opt/$USER/kube.conf /home/$USER/.kube/config
# RUN /bin/chown $USER:$USER -R /home/$USER


# ╭――――――――――――――――――――╮
# │ SETTINGS           │
# ╰――――――――――――――――――――╯
USER $USER
VOLUME /mnt/volumes/backup
VOLUME /mnt/volumes/configmaps
VOLUME /mnt/volumes/container
EXPOSE 8080/tcp
WORKDIR /home/$USER

# ╭――――――――――――――――――――╮
# │ CONFIGURE          │
# ╰――――――――――――――――――――╯
RUN /usr/bin/yarn global add wetty
COPY setup-vault /home/$USER/.scripts/setup-vault
COPY setup-client-ca /home/$USER/.scripts/setup-client-ca
RUN ln -s /home/$USER/.scripts/setup-vault /home/$USER/setup-vault \
 && ln -s /home/$USER/.scripts/setup-client-ca /home/$USER/setup-client-ca
RUN /bin/mkdir -p ~/.kube
