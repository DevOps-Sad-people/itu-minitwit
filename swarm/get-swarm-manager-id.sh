#!/bin/bash

export JQFILTER='.droplets | .[] | select (.name == "minitwit.manager") 
	| .networks.v4 | .[]| select (.type == "public") | .ip_address'


export SWARM_MANAGER_IP=$(curl -s GET "$DROPLETS_API"\
    -H "$BEARER_AUTH_TOKEN" -H "$JSON_CONTENT"\
    | jq -r "$JQFILTER") && echo "SWARM_MANAGER_IP=$SWARM_MANAGER_IP"
