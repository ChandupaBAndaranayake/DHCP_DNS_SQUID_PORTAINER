FROM alpine:latest

RUN apk add --no-cache \
    bash \
    build-base \
    perl \
    wget \
    tar \
    linux-headers

RUN wget https://ftp.isc.org/isc/dhcp/4.4.3-P1/dhcp-4.4.3-P1.tar.gz \
    && tar xzf dhcp-4.4.3-P1.tar.gz \
    && cd dhcp-4.4.3-P1 \
    && ./configure \
    && make \
    && make install

RUN mkdir -p /etc/dhcp /var/db /var/run \
    && touch /var/db/dhcpd.leases

COPY DHCP_setup.sh /DHCP_setup.sh 

RUN chmod +x /DHCP_setup.sh

EXPOSE 67/udp
ENTRYPOINT [ "/DHCP_setup.sh" ]