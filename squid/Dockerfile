FROM alpine:latest

RUN apk add --no-cache squid bash su-exec

COPY SQUID_setup.sh /SQUID_setup.sh
RUN chmod +x /SQUID_setup.sh

EXPOSE 3128
ENTRYPOINT ["/SQUID_setup.sh"]
