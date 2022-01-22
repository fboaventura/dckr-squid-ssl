FROM ubuntu:impish

ENV PS1 "squid-server $PS1"
ENV DEBIAN_FRONTEND "noninteractive"
ENV TZ "America/Sao_Paulo"

RUN apt-get -y update \
    && apt-get upgrade -y \
    && apt-get install -y supervisor openssl curl wget iputils-ping htop squid-langpack \
               squid-cgi squid-openssl ca-certificates \
    && mkdir -p /var/log/supervisor /app/var/cache /app/var/lib /app/var/log /app/squid/certs \
             /etc/squid/db /etc/squid/certs \
    && chown -R proxy:proxy /app \
    && apt clean -y \
    && rm -rf /var/lib/apt/lists/*

COPY files /files

RUN /usr/lib/squid/security_file_certgen -c -s /etc/squid/db/ssl_db -M 16MB \
    && /usr/sbin/squid -N -f /files/squid.conf -z \
    && cp /files/supervisord.conf /etc/supervisor/conf.d/supervisord.conf \
    && cp /files/squid* /app/squid/ \
    && cp /files/docker-entrypoint.sh /app/ \
    && chmod 750 /app/docker-entrypoint.sh

WORKDIR /app/

EXPOSE 3128 3129

CMD ["/bin/bash" ,"/app/docker-entrypoint.sh"]

ARG BUILD_DATE
ARG VCS_REF
ARG VENDOR
ARG VERSION
ARG AUTHOR

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="Squid-Cache" \
      org.label-schema.description="Squid proxy with SSL support" \
      org.label-schema.url="https://fboaventura.dev" \
      org.label-schema.vcs-url="https://github.com/fboaventura/dckr-squid-ssl" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vendor="$VENDOR" \
      org.label-schema.version="$VERSION" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.author="Frederico Freire Boaventura" \
      org.label-schema.docker.dockerfile="/Dockerfile" \
      org.label-schema.license="Apache 2.0"
