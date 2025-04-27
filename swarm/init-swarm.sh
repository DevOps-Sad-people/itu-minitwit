#!/bin/bash

# Ininit and get worker token
ssh root@$SWARM_MANAGER_IP "docker swarm init --advertise-addr $SWARM_MANAGER_IP"
export WORKER_TOKEN=`ssh root@$SWARM_MANAGER_IP "docker swarm join-token worker -q"`

# The command to join the worker nodes to the swarm
REMOTE_JOIN_CMD="docker swarm join --token $WORKER_TOKEN $SWARM_MANAGER_IP:2377"

# Join the worker nodes to the swarm
ssh root@$WORKER1_IP "$REMOTE_JOIN_CMD"
ssh root@$WORKER2_IP "$REMOTE_JOIN_CMD"

# Status of the Swarm
ssh root@$SWARM_MANAGER_IP "docker node ls"
