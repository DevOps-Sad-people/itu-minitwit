# Reflection

## Evolution and refactoring
Finishing a sprint and adding a new feature 

### [G/Z] ELK logging resource heavy + too many fields + all fields were indexed


### [G/Z] Filebeat on all swarm nodes


### [G/Z] Logging deployment: put config images in


### [Nic] Database migrating from SQLite to PostgreSQL to PostgreSQL
The migration from SQLite to Postgresql happened at a stage, where no active users was using our platform (The simulator was yet to start). This meant that we could safely upgrade without having to move over data, which would have otherwise been a hassle given the SQL dissimilarities.

Given the educational purpose of the project, we later sought out an opportunity to perform a database migration. Such an opportunity arose when database optimization became a necessity. Before optimizing, we deemed it necessary to introduce an ORM, which would improve the developer experience as well as migration experience going forward. Given the new database structure introduced by the ORM, although quite similar, we needed to migrate from one database with one schema, to another database with another schema. The approach taken involved extracting data from one postgres instance in the shape of SQL Insertion statement, which we then manipulated to fit the new data scheme, and then simply ran the sql insertion statements in the new database.

As soon as the migration was done, we switched to the new application image, meaning we now served requests from the new database. This approach involved having 5 minutes of forgotten data, and 3 seconds of lost availability. We found this price and strategy reasonable, although the 5 minutes of lost data, could have had serious impact on the business. As we will later discuss, we found that using logical replication, proved to be a much nicer approach to copying data.


### [Nic] Transition from docker compose to docker swarm (networking problems).
Transitioning onto multiple machines with docker swarm came with multiple obstacles. First, the docker compose version running on certain of the docker compose scripts, were unsupported by docker swarm. WRITE HERE, WRITE HERE **[Seb/Nick] Docker compose versioning problem (moving to stack)**.

Second, the swarm nodes were able to communicate with each other, but self-instantiated virtual networks defined in the docker-compose file, did not propagate to worker nodes, leaving application containers unable to contact the database, and prometheus unable to collect monitoring events. To accommodate the issue, we destroyed and redeployed new virtual machines, and this time used the VPC IP address to define the IP address of the manager node. This meant that workers are referring to the manager using the virtual network layer, and solved the communication issue.


### [G/Z] scp files onto server and then deployment (Discuss ups/downs)
    - You can destroy the prod environment with wrong files/wrong docker compose
  

### [G/Z] Transition from config files to docker images (Tagging docker containers) 



### [Seb/Nick] Large amount of features cloging up in staging (Impossible to migrate to production)



## Operation
Keep the system running

### [Nic] Database logical replication resulting in db crash
Migrating from docker compose to the docker swarm included the use of postgres feature: Logical replication, which allows postgres instances to live sync data from running postgres instance to the other. This feature is typically used to keep a hot stand-in database ready. In our case, it meant we would actively sync data from the active production database, onto the new production database, and allow us to switch from one stack to the other with zero downtime, as the stand-in database would become the new default.

Unfortunately, after switching a few days later, the pub/sub mechanism of logical replication in Postgres accidentally corrupted a tracking file, meaning the postgres would immediately crash on start. This problem was accomodated by immediately running `pg_resetwal` on startup to reset the corrputed file, and then unsubscriping from the expired subscription. The subscription does not provide any value at this point, as we swapped from the old to the new production machine, and the old one has been turned off.


### [G/Z]Log overflow problem. Access denied to machine. Massive clutch



### [Nic] Backup strategy (cron job every three hours)
Although it's great to solve problems on yuor own, sometimes other have done a great job already. And this proved to be the case for backing up a Postgres database. Simply adding the `eeshugerman/postgres-backup-s3:15` container image to the manager node and configuring environment variables, we successfully setup a cron job that automatically backs up daily, and sends the backup to DO's space storage, which is S3 compatible. Using the exact same script, it also includes functions that easily allow restoring from a previous backup. The latter is a crucial step, for when things are burning. The container likewise provide clean-up functionality, such that only 7 days of backups are kept.


## Maintenance
Keep system up to date and fix bugs 
### [Seb/Nick] Stale ReadMe.md throughout project
### [Seb/Nick]Returning wrong statuscode (Misalignment with simulation) 
   - Thanks to running similator in the CI/CD pipeline we found this
### [Nic] Upgrading to NGINX, setting up ufw, moving to domain
Upgrading to NGINX, we learned multiple things about running a system. First being that having a staging environment to learn how to run command in the correct order proved great to build a shell script that immediately upgrades the production service. Second, that although we had configured our ufw with all the right ports, actually the service was disabled, which it is by default. Only by realizing that the 443 port was open although no specified, did we realize that ufw needs to be actively activated. From this we gathered, that it is important to double check firewall and other security measures, to ensure they're configured properly. Luckily, our database was not exposed by PORT from the docker network, and therefore inaccessible, but having full access to other ports may have exposed other vulnerabilities on the machine.

### [Nic] Simulator IP protection stopped sim access (causing errors)
Refactoring simulator requests to only be accepted from a single IP address helped us prevent other malicious users from interfering with the active simulation requests. However, when the new update was pushed, unfortunately the IP protection feature also protected us from the actual simulation IP. Although this worked perfect locally, moving it onto production showed that the feature declined all sim api requests. From this we learned about the importance of being able to quickly roll back an update. During this experience, we found that we did not have a previous versioned container ready to roll back to, and instead had to allow all IP's which was possibly by passing in `ACCEPTED_IPS=*`, which essentially disabled the IP protection.

## Style of work
Reflect and describe what was the "DevOps" style of your work.
### [Seb/Nick] Reflect on the workflow. Extensive Friday meeting. Split work into three groups
### [Seb/Nick] Development environemnt: local => branch => staging => production
### [Seb/Nick] Repo settings. Workflows on merge. Require 1 team member on pull requests.
### [Seb/Nick] Running simulator in workflows
