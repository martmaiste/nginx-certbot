#!/bin/sh

cd /etc/letsencrypt/live/localhost && generate-certs && cat cert.pem ca.pem > fullchain.pem && cat key.pem > privkey.pem
