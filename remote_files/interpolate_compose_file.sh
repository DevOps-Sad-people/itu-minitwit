#!/bin/bash

set -ae
source .env
set +a

# Surround env values in the compose file with quotes to escape special yaml interpretation.
# E.g.   ${...} --> "${...}"
# Then subsitute values and return the interpolated compose file.
cat docker-compose.yml | sed 's/\${\([^}]*\)}/"\${\1}"/g' | envsubst
