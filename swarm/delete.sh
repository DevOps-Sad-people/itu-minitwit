#!/bin/bash

curl -X DELETE\
  -H "$BEARER_AUTH_TOKEN" -H "$JSON_CONTENT"\
  "https://api.digitalocean.com/v2/droplets?tag_name=demo"