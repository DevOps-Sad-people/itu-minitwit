# Reflection

## Evolution and refactoring
Finishing a sprint and adding a new feature 

### [G/Z] ELK logging resource heavy + too many fields + all fields were indexed


### [G/Z] Filebeat on all swarm nodes


### [G/Z] Logging deployment: put config images in


### [Nic] Migrating from SQLite to PostgreSQL


### [Nic] Transition from docker compose to docker swarm (networking problems).


### [Seb/Nick] Docker compose versioning problem (moving to stack)


### [G/Z] scp files onto server and then deployment (Discuss ups/downs)
    - You can destroy the prod environment with wrong files/wrong docker compose
  

### [G/Z] Transition from config files to docker images (Tagging docker containers) 



### [Seb/Nick] Large amount of features cloging up in staging (Impossible to migrate to production)



## Operation
Keep the system running

### [Nic] Database logical replication resulting in db crash



### [G/Z]Log overflow problem. Access denied to machine. Massive clutch



### [Nic] Backup strategy (cron job every three hours)




## Maintenance
Keep system up to date and fix bugs 
### [Seb/Nick] Stale ReadMe.md throughout project
### [Seb/Nick]Returning wrong statuscode (Misalignment with simulation) 
   - Thanks to running similator in the CI/CD pipeline we found this
### [Nic] Upgrading to NGINX, setting up ufw, moving to domain
### [Nic] Simulator IP protection stopped sim access (causing errors)


## Style of work
Reflect and describe what was the "DevOps" style of your work.
### [Seb/Nick] Reflect on the workflow. Extensive Friday meeting. Split work into three groups
### [Seb/Nick] Development environemnt: local => branch => staging => production
### [Seb/Nick] Repo settings. Workflows on merge. Require 1 team member on pull requests.
### [Seb/Nick] Running simulator in workflows
