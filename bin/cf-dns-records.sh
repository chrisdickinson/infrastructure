#!/bin/bash

curl -sL https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_ZONE_ID}/dns_records \
  -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
  -H 'content-type: application/json'

