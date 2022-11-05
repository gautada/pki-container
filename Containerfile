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
COPY pki-setup /usr/bin/pki-setup
COPY vault-setup /usr/bin/vault-setup
COPY vault-mount /usr/bin/vault-mount
COPY vault-umount /usr/bin/vault-umount
COPY vault-refresh /usr/bin/vault-refresh
COPY ca-server /usr/bin/ca-server
COPY ca-client /usr/bin/ca-client
COPY ca-revoke /usr/bin/ca-revoke
COPY vault-monitor /etc/periodic/15min/vault-monitor
RUN update-ca-certificates \
 && /bin/mkdir -p /mnt/ca-root /mnt/ca /var/log/letsencrypt /var/lib/letsencrypt \
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
RUN /bin/mkdir -p /opt/$USER /mnt/ca-root /mnt/ca \
 && /usr/sbin/addgroup $USER \
 && /usr/sbin/adduser -D -s /bin/ash -G $USER $USER \
 && /usr/sbin/usermod -aG wheel $USER \
 && /bin/echo "$USER:$USER" | chpasswd \
 && /bin/chown $USER:$USER -R /opt/$USER /mnt/ca-root /mnt/ca
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
