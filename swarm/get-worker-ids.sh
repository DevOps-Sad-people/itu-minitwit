#!/bin/bash


export JQFILTER='.droplets | .[] | select (.name == "minitwit.worker1") | .networks.v4 | .[]| select (.type == "public") | .ip_address'

export WORKER1_IP=$(curl -s GET "$DROPLETS_API"\
    -H "$BEARER_AUTH_TOKEN" -H "$JSON_CONTENT"\
    | jq -r "$JQFILTER")\
    && echo "WORKER1_IP=$WORKER1_IP"

export JQFILTER='.droplets | .[] | select (.name == "minitwit.worker2") | .networks.v4 | .[]| select (.type == "public") | .ip_address'

export WORKER2_IP=$(curl -s GET "$DROPLETS_API"\
    -H "$BEARER_AUTH_TOKEN" -H "$JSON_CONTENT"\
    | jq -r "$JQFILTER")\
    && echo "WORKER2_IP=$WORKER2_IP"