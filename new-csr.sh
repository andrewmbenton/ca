#!/bin/sh
openssl req -new -utf8 -newkey 2048 -nodes -keyout "$DNS_NAME.key" \
    -subj "/" -addext "subjectAltName = critical, DNS:$DNS_NAME" | tee "$DNS_NAME.csr" | base64 -w0 > "$DNS_NAME.csr.b64"
