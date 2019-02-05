# Stick to libressl 2.6
# https://github.com/PowerDNS/pdns/issues/6943
FROM alpine
MAINTAINER Milosz Szewczak <milek@milek.eu>

ENV REFRESHED_AT="2018-12-27" \
    POWERDNS_VERSION=4.1.6 \
    PGSQL_AUTOCONF=true \
    PGSQL_HOST="postgres" \
    PGSQL_PORT="5432" \
    PGSQL_USER="postgres" \
    PGSQL_PASS="root" \
    PGSQL_DB="pdns"

# alpine:3.8: mariadb-connector-c-dev

RUN apk --update add libpq sqlite-libs libstdc++ libgcc mariadb-client postgresql-client && \
    apk add --virtual build-deps \
      g++ make mariadb-dev postgresql-dev sqlite-dev curl boost-dev && \
    curl -sSL https://downloads.powerdns.com/releases/pdns-$POWERDNS_VERSION.tar.bz2 | tar xj -C /tmp && \
    cd /tmp/pdns-$POWERDNS_VERSION && \
    ./configure --prefix="" --exec-prefix=/usr --sysconfdir=/etc/pdns \
      --with-modules="bind gmysql gpgsql gsqlite3" --without-lua && \
    make && make install-strip && cd / && \
    mkdir -p /etc/pdns/conf.d && \
    addgroup -S pdns 2>/dev/null && \
    adduser -S -D -H -h /var/empty -s /bin/false -G pdns -g pdns pdns 2>/dev/null && \
    cp /usr/lib/libboost_program_options-mt.so* /tmp && \
    apk del --purge build-deps && \
    mv /tmp/libboost_program_options-mt.so* /usr/lib/ && \
    rm -rf /tmp/pdns-$POWERDNS_VERSION /var/cache/apk/*

ADD schema.pgsql.sql /etc/pdns/
COPY pg_pdns.conf /etc/pdns/pdns.conf
ADD pg_entrypoint.sh /

EXPOSE 53/tcp 53/udp

ENTRYPOINT ["/pg_entrypoint.sh"]
