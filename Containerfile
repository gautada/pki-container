ARG ALPINE_VERSION=3.16.2
# ╭――――――――――――――――---------------------------------------------------------――╮
# │                                                                           │
# │ STAGE 1: configure-pki -- Pull and configure the ppki environment         │
# │                                                                           │
# ╰―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╯
FROM gautada/alpine:$ALPINE_VERSION as configure-pki

# ╭――――――――――――――――――――╮
# │ METADATA           │
# ╰――――――――――――――――――――╯
LABEL source="https://github.com/gautada/pki-container.git"
LABEL maintainer="Adam Gautier <adam@gautier.org>"
LABEL description="PKI container provides all of the requirements for maintaining a useful public-key infrastructure."

# ╭――――――――――――――――――――╮
# │ ENVIRONMENT        │
# ╰――――――――――――――――――――╯
RUN ln -s /etc/container/configmap.d /etc/letsencrypt

# ╭――――――――――――――――――――╮
# │ ENTRYPOINT         │
# ╰――――――――――――――――――――╯
COPY 10-ep-container.sh /etc/container/entrypoint.d/10-ep-container.sh

# ╭――――――――――――――――――――╮
# │ PACKAGES           │
# ╰――――――――――――――――――――╯
# Previously Loaded: nmap sudo shadow
RUN apk add --no-cache --update build-base e2fsprogs easypki cryptsetup git npm openssh-client openssh openssl python3 py3-augeas py3-cryptography py3-pip yarn

# ╭――――――――――――――――――――╮
# │ CONFIGURE          │
# ╰――――――――――――――――――――╯
# COPY vault-domain-setup /usr/bin/vault-domain-setup
# COPY vault-setup /usr/bin/vault-setup
# COPY vault-mount /usr/bin/vault-mount
# COPY vault-umount /usr/bin/vault-umount
# COPY vault-refresh /usr/bin/vault-refresh
# COPY vault-monitor /usr/bin/vault-monitor
# COPY ca-server /usr/bin/ca-server
# COPY ca-client /usr/bin/ca-client
# COPY ca-revoke /usr/bin/ca-revoke
# COPY pki-export /usr/bin/pki-export
RUN ln -s /opt/pki/scripts/vault-domain-setup /usr/bin/vault-domain-setup \
 && ln -s /opt/pki/scripts/vault-setup /usr/bin/vault-setup \
 && ln -s /opt/pki/scripts/vault-mount /usr/bin/vault-mount \
 && ln -s /opt/pki/scripts/vault-umount /usr/bin/vault-umount \
 && ln -s /opt/pki/scripts/vault-refresh /usr/bin/vault-refresh \
 && ln -s /opt/pki/scripts/vault-monitor /usr/bin/vault-monitor \
 && ln -s /opt/pki/scripts/ca-server /usr/bin/ca-server \
 && ln -s /opt/pki/scripts/ca-client /usr/bin/ca-client \
 && ln -s /opt/pki/scripts/ca-revoke /usr/bin/ca-revoke \
 && ln -s /opt/pki/scripts/pki-export /usr/bin/pki-export
 
RUN ln -s /usr/bin/vault-monitor /etc/periodic/15min/vault-monitor
RUN update-ca-certificates \
 && /bin/mkdir -p /mnt/vault /var/log/letsencrypt /var/lib/letsencrypt \
 && /usr/bin/pip install --upgrade pip \
 && /usr/bin/pip install certbot
# - - - CERTBOT - - -
COPY auth-hook /usr/bin/auth-hook
COPY hover-auth-hook.py /usr/bin/hover-auth-hook
COPY certbot-wrapper /usr/bin/certbot-wrapper
RUN ln -s /usr/bin/certbot-wrapper /etc/periodic/15min/certbot-wrapper
COPY certbot-upgrade /usr/bin/certbot-upgrade
RUN ln -s /usr/bin/certbot-upgrade /etc/periodic/monthly/certbot-upgrade
RUN ln -s /opt/acme/auth.env /etc/container/configmap.d/auth.env

# ╭――――――――――――――――――――╮
# │ SUDO               │
# ╰――――――――――――――――――――╯
COPY wheel-ssh /etc/container/wheel.d/wheel-ssh
COPY wheel-pki /etc/container/wheel.d/wheel-pki
COPY wheel-pip /etc/container/wheel.d/wheel-pip
COPY wheel-tee /etc/container/wheel.d/wheel-tee

# ╭――――――――――――――――――――╮
# │ USER               │
# ╰――――――――――――――――――――╯
ARG UID=1001
ARG GID=1001
ARG USER=pki
# VOLUME /opt/$USER
RUN /bin/mkdir -p /opt/$USER \
 && /usr/sbin/addgroup -g $GID $USER \
 && /usr/sbin/adduser -D -G $USER -s /bin/ash -u $UID $USER \
 && /usr/sbin/usermod -aG wheel $USER \
 && /bin/echo "$USER:$USER" | chpasswd \
 && /bin/chown $USER:$USER -R /opt/$USER
USER $USER
WORKDIR /home/$USER

# ╭――――――――――――――――――――╮
# │ PORTS              │
# ╰――――――――――――――――――――╯
EXPOSE 8080

# ╭――――――――――――――――――――╮
# │ CONFIGURE          │
# ╰――――――――――――――――――――╯
RUN /usr/bin/yarn global add wetty
