#!/bin/sh
openssl req -x509 -newkey rsa:4096 -sha256 -keyout "$CA_NAME.combined.pem" -noenc \
    -subj "/CN=$CA_NAME" -days 3650 | tee "$CA_NAME.cert.pem" >> "$CA_NAME.combined.pem"
