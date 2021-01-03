FROM alpine:3.12.1 as config-alpine

RUN apk add --no-cache tzdata

RUN cp -v /usr/share/zoneinfo/America/New_York /etc/localtime
RUN echo "America/New_York" > /etc/timezone

FROM alpine:3.12.1

RUN apk add --no-cache e2fsprogs easypki cryptsetup git lvm2 openssl parted

ENV PKI_ROOT=/opt/pki/vaults/
ENV PKI_ORGANIZATION="Adam Gautier"
ENV PKI_ORGANIZATIONAL_UNIT=Personal
ENV PKI_COUNTRY=US
ENV PKI_LOCALITY=Charlotte
ENV PKI_PROVINCE="North Carolina"

COPY ca-setup /usr/bin/ca-setup
COPY ca-refresh /usr/bin/ca-refresh
COPY ca-server /usr/bin/ca-server
COPY ca-client /usr/bin/ca-client
COPY ca-revoke /usr/bin/ca-revoke
COPY vault-mount /usr/bin/vault-mount
COPY vault-umount /usr/bin/vault-umount
 
RUN git config --global user.email "pki@gautier.org"
RUN git config --global user.name "PKI Vault"
RUN git config --global credential.helper store
RUN mkdir -p /opt/pki-data \
 && echo "date +%s > /opt/docker/pki/vaults/root/.last" > /root/.ash_history \
 && echo "date +%s > /opt/docker/pki/vaults/ca.gautier.org/.last" > /root/.ash_history

CMD ["tail", "-f", "/dev/null"]
