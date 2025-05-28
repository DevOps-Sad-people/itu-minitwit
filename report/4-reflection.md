# Reflection

## Evolution and refactoring
Finishing a sprint and adding a new feature 


### [Nic] Database migrating from SQLite to PostgreSQL to PostgreSQL
The migration from SQLite to Postgresql happened at a stage, where no active users was using our platform (The simulator was yet to start). This meant that we could safely upgrade without having to move over data, which would have otherwise been a hassle given the SQL dissimilarities.

Given the educational purpose of the project, we later sought out an opportunity to perform a database migration. Such an opportunity arose when database optimization became a necessity. Before optimizing, we deemed it necessary to introduce an ORM, which would improve the developer experience as well as migration experience going forward. Given the new database structure introduced by the ORM, although quite similar, we needed to migrate from one database with one schema, to another database with another schema. The approach taken involved extracting data from one postgres instance in the shape of SQL Insertion statement, which we then manipulated to fit the new data scheme, and then simply ran the sql insertion statements in the new database.

As soon as the migration was done, we switched to the new application image, meaning we now served requests from the new database. This approach involved having 5 minutes of forgotten data, and 3 seconds of lost availability. We found this price and strategy reasonable, although the 5 minutes of lost data, could have had serious impact on the business. As we will later discuss, we found that using logical replication, proved to be a much nicer approach to copying data.


### [Nic] Transition from docker compose to docker swarm (networking problems).
Transitioning onto multiple machines with docker swarm came with multiple obstacles.

**[Seb/Nick] Docker compose versioning problem (moving to stack)**.  

Firstly, the docker compose version that supports `docker stack deploy` is a legacy version of docker, and there is a difference in the features and syntax supported which caused some problems. The `docker stack` does not take `build`, `container_name` and `depend_on` into consideration, and also handles unnamed volumes differently. Therefore, we had to rewrite the compose scripts to make them compatible with docker stack. One of the biggest change that also resulted from this is that from this point on, we had to build the configuration files of each service into Docker images, and publish them to our DigitalOcean registry. This came with several complications, such as automatically building images in our workflows during deployment, and ensuring correct versioning/tagging for each image, since publishing all images in every deployment would take a lot of resources and time. This change also solved another one of our problems: previously, we manually copied all configuration files onto the server using `scp`, which made every deployment error prone.

Secondly, the swarm nodes were able to communicate with each other, but self-instantiated virtual networks defined in the docker-compose file, did not propagate to worker nodes, leaving application containers unable to contact the database, and prometheus unable to collect monitoring events. To accommodate the issue, we destroyed and redeployed new virtual machines, and this time used the VPC IP address to define the IP address of the manager node. This meant that workers are referring to the manager using the virtual network layer, and solved the communication issue.


### [G/Z] Logging issues (ELK logging resource heavy + too many fields + all fields were indexed, Filebeat on all swarm nodes)

The initial deployment of our logging stack was quite problematic, as Elasticsearch turned out to be very resource heavy, consuming almost ~60-80% CPU at times (before introducing logging, it was ~10% at peak load), and also taking all available RAM. We tackled this in two ways:
- We scaled the droplets vertically, giving them more resources, as previously discussed. This was necessary because the stack has larger minimal resource requirements than what we had.
- We introduced Logstash filters, which dramatically decreased the number of fields indexed by Elasticsearch, lowering its resource consumption greatly.

We also encountered another issue with Filebeat, after switching to Docker Swarm. We found that one Filebeat instance needs to run on each node, because every instance needs direct access to read the containers' log files. This was solved by introducing global replication for not only the Minitwit application, but for Filebeat as well.


### [Seb/Nick] Large amount of features cloging up in staging (Impossible to migrate to production)

Implementing new features fully sometimes took longer than a week. Due to the development workflow described earlier the staging environment was used as a development/testing environment. This resulted in features gate keeped by ohter not fully implemented features. 

Some of the new features required changing the other features, such as the migration from docker compose to docker stack required a full rewrite of the docker compose scripts. 

This made it impossible to migrate the changes to production and delayed the release of the full implementation of the logging and monitoring.  

## Operation
Keep the system running

### [Nic] Database logical replication resulting in db crash
Migrating from docker compose to the docker swarm included the use of postgres feature: Logical replication, which allows postgres instances to live sync data from running postgres instance to the other. This feature is typically used to keep a hot stand-in database ready. In our case, it meant we would actively sync data from the active production database, onto the new production database, and allow us to switch from one stack to the other with zero downtime, as the stand-in database would become the new default.

Unfortunately, after switching a few days later, the pub/sub mechanism of logical replication in Postgres accidentally corrupted a tracking file, meaning the postgres would immediately crash on start. This problem was accomodated by immediately running `pg_resetwal` on startup to reset the corrputed file, and then unsubscriping from the expired subscription. The subscription does not provide any value at this point, as we swapped from the old to the new production machine, and the old one has been turned off.


### [G/Z] Log overflow problem. Access denied to machine. Massive clutch

After quite some time into development, our droplet became overwhelmed by the large volume of logs being generated by the different containers. This log overflow consumed all available disk space on our droplet, resulting in the droplet becoming inoperable, also shutting down our whole system. We did not notice this issue for a few days as Grafana also shut down, being unable to send alerts to us. After noticing the issue, we were also denied SSH access into the droplet. We had to use DigitalOcean's recovery console to regain access to the server, delete unnecessary log files, and restore normal operation. Learning from this incident, we introduced log rotation in our docker compose file which limits the maximum number and size of generated log files.


### [Nic] Backup strategy (cron job every three hours)
Although it's great to solve problems on your own, sometimes other have done a great job already. And this proved to be the case for backing up a Postgres database. Simply adding the `eeshugerman/postgres-backup-s3:15` container image to the manager node and configuring environment variables, we successfully setup a cron job that automatically backs up daily, and sends the backup to DO's space storage, which is S3 compatible. Using the exact same script, it also includes functions that easily allow restoring from a previous backup. The latter is a crucial step, for when things are burning. The container likewise provide clean-up functionality, such that only 7 days of backups are kept.


## Maintenance
Keep system up to date and fix bugs 
### [Seb/Nick] MAYBE NOT NECCESSAY TO DISCUSS THIS Stale ReadMe.md throughout project
### [Seb/Nick] Returning wrong statuscode (Misalignment with simulation)

We implemented the simulator test in our testing workflow. It runs to ensure that the endpoints are available, works and return the correct status codes. After we had implemented the simulator test they failed and we realised that one of our enpoints was misaligned the specification. The endpoint returned the wrong status code. By implementing the simulator tests we discovered the issue in a very early stage.  

### [Nic] Upgrading to NGINX, setting up ufw, moving to domain
Upgrading to NGINX, we learned multiple things about running a system. First being that having a staging environment to learn how to run command in the correct order proved great to build a shell script that immediately upgrades the production service. Second, that although we had configured our ufw with all the right ports, actually the service was disabled, which it is by default. Only by realizing that the 443 port was open although no specified, did we realize that ufw needs to be actively activated. From this we gathered, that it is important to double check firewall and other security measures, to ensure they're configured properly. Luckily, our database was not exposed by PORT from the docker network, and therefore inaccessible, but having full access to other ports may have exposed other vulnerabilities on the machine.

### [Nic] Simulator IP protection stopped sim access (causing errors)
Refactoring simulator requests to only be accepted from a single IP address helped us prevent other malicious users from interfering with the active simulation requests. However, when the new update was pushed, unfortunately the IP protection feature also protected us from the actual simulation IP. Although this worked perfect locally, moving it onto production showed that the feature declined all sim api requests. From this we learned about the importance of being able to quickly roll back an update. During this experience, we found that we did not have a previous versioned container ready to roll back to, and instead had to allow all IP's which was possibly by passing in `ACCEPTED_IPS=*`, which essentially disabled the IP protection.

## Style of work
Reflect and describe what was the "DevOps" style of your work.
### [Seb/Nick] Reflect on the workflow. Extensive Friday meeting. Split work into three groups

Each Friday after the lectures we met up to have an extensive meeting about the current state of the project. First we shared what features we had worked on the past week, what kind of problems we had faced and how we had solved them. We did this to keep everyone up to date with all the different new technologies and featues implemented. 

Second we discussed the content of the lecture and inspected what new features to implement in the next week. Then we discussed *how* to implement the new features and the pros and cons of the different options. For each tasks we created a new issue on GitHub.

Third we discussed *when* to implement the new issues. The group members had different schedules and varying capacity due to other commitments such as handins for other courses. We took this into considaration when we delegated the work. We typically worked in three teams:

1. Nicolaj
2. Gabor and Zalan
3. Sebastian and Nicklas

These Friday meetings worked very well for us, as we all had a very busy schedule. These meetings allowed us to delegate the work, inspect the progess, adapt the plan and be up to date in terms of the implementation details. While still going in depth into the subjects.


### [Seb/Nick] MERGE THIS INTO PROCESS SECTION Development environemnt: local => branch => staging => production

As explain in the [Proceess section](3-process.md) we wen developing a new fea

When developing new features you branch off `develop` then implement the changes and test them **locally** via the local docker development environment `dovker-compose.dev.yml`. Then changes are pushed to a remote branch so another person can continue working on the changes. When the feature/tasks is completed a pull request is created. When the changes are approved they merge into `develop` and trigger a new deployment to the staging environment. If the changes work in the staging environment a pull request from `develop` into `main` can be created. Once the pull request is approved a new release and deployment to production is triggered.  


