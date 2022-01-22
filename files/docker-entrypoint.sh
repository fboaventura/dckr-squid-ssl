#!/bin/bash

export SQUID_CONF="${SQUID_CONF:-cache}"
export LANG="${LANG:-en}"
export HOST="${HOST:-proxy.local}"
export COUNTRY="${COUNTRY:-BR}"
export STATE="${STATE:-Espirito Santo}"
export LOCALITY="${LOCALITY:-Vila Velha}"
export ORGANIZATION="${ORGANIZATION:-FFBDev}"
export OU="${OU:-IT}"
export EMAIL="${EMAIL:-admin@proxy.local}"

if [[ ! -f "/app/squid/certs/squid-ca-cert.pem" || ! -f "/app/squid/certs/squid-ca-key.pem" ]]; then
  sed -i "s/%%%HOST%%%/${HOST}/g" /files/sans.cfg
  openssl req -new -newkey rsa:2048 -sha256 -days 3650 -nodes -x509 -config /files/sans.cfg \
   -subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCALITY}/O=${ORGANIZATION}/OU=${OU}/CN=${HOST}/emailAddress=${EMAIL}" \
   -keyout /app/squid/certs/squid-ca-key.pem -out /app/squid/certs/squid-ca-cert.pem
fi

cat /app/squid/certs/squid-ca-cert.pem /app/squid/certs/squid-ca-key.pem > /etc/squid/certs/squid-ca-cert-key.pem
echo -e "=-=-=-=-=-=-=-=-=-=-=-=-= Squid CA  Certificate =-=-=-=-=-=-=-=-=-=-=-=-="
openssl x509 -in /app/squid/certs/squid-ca-cert.pem -noout -subject -issuer -startdate -enddate
echo -e "=-=-=-=-=-=-=-=-=-=-=-=-= Squid CA  Certificate =-=-=-=-=-=-=-=-=-=-=-=-="
cat /app/squid/certs/squid-ca-cert.pem
echo -e "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="

sed -e "s/%%%LANG%%%/${LANG}/g; \
        s/%%%HOST%%%/${HOST}/g" "/files/squid.conf.${SQUID_CONF}" > /etc/squid/squid.conf

echo -e "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
echo -e "Creating cache folders"
echo -e "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
/usr/sbin/squid -N -f /etc/squid/squid.conf -z 1>/dev/mull 2>&1 || true
echo -e "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
echo -e "Starting supervisord"
echo -e "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
/usr/bin/supervisord --configuration /etc/supervisor/conf.d/supervisord.conf
echo -e "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
