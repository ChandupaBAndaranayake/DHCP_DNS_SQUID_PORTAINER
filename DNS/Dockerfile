FROM alpine:latest

RUN apk add --no-cache bind bind-tools bash

COPY DNS_setup.sh /DNS_setup.sh
RUN chmod +x /DNS_setup.sh

EXPOSE 53/udp 53/tcp
ENTRYPOINT ["/DNS_setup.sh"]