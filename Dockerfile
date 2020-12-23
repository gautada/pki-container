FROM alpine:3.12.1

RUN apk add --no-cache easypki git openssl tzdata

RUN cp /usr/share/zoneinfo/America/New_York /etc/localtime \
 && echo "America/New_York" > /etc/timezone

ENV PKI_ROOT=/opt/pki/vaults/
ENV PKI_ORGANIZATION="Adam Thomas Gautier"
ENV PKI_ORGANIZATIONAL_UNIT=Personal
ENV PKI_COUNTRY=US
ENV PKI_LOCALITY=Charlotte
ENV PKI_PROVINCE="North Carolina"

COPY ca-setup /bin/ca-setup
COPY ca-refresh /bin/ca-refresh
COPY ca-server /bin/ca-server
COPY ca-client /bin/ca-client
COPY ca-revoke /bin/ca-revoke

RUN chmod +x /bin/ca-* \
 && rm -rf /var/cache/apk/* \
 && mkdir -p /opt/docker/pki \
 && echo "date +%s > /opt/docker/pki/vaults/root/.last" > /root/.ash_history \
 && echo "date +%s > /opt/docker/pki/vaults/ca.gautier.org/.last" > /root/.ash_history

VOLUME ["/opt/pki"]

CMD ["tail", "-f", "/dev/null"]
