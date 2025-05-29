# Reflection

## Evolution and refactoring

### Database migrations
The [first migration](https://github.com/DevOps-Sad-people/itu-minitwit/issues/65) from SQLite to Postgresql happened at a stage, where no active users were using our platform (The simulator was yet to start). This meant that we could safely upgrade without having to move over data, which would have otherwise been a hassle given the SQL dissimilarities.

Given the educational purpose of the project, we later sought out an opportunity to perform another database migration. Such an opportunity arose when database optimization became a necessity. Before optimizing, we deemed it necessary to introduce an ORM (see [Issue#85](https://github.com/DevOps-Sad-people/itu-minitwit/issues/85) and [Issue121](https://github.com/DevOps-Sad-people/itu-minitwit/issues/121)), which would improve the developer experience as well as migration experience going forward. Given the new database structure introduced by the ORM, although quite similar, we needed to [migrate](https://github.com/DevOps-Sad-people/itu-minitwit/issues/127) from one database with one schema, to another database with another schema. The approach taken involved extracting data from one postgres instance in the shape of SQL Insertion statement, which we then manipulated to fit the new data schema, and then simply ran the SQL insertion statements in the new database.

As soon as the migration was done, we switched to the new application image, meaning we now served requests from the new database. This approach involved having 5 minutes of forgotten data, and 3 seconds of lost availability. We found this price and strategy reasonable, although the 5 minutes of lost data, could have had serious impact on the business. As we will later discuss, we found that using logical replication proved to be a much nicer approach to copying data.


### Transition from docker compose to docker swarm (networking problems).
[Transitioning](https://github.com/DevOps-Sad-people/itu-minitwit/issues/189) onto a cluster of machines with docker swarm came with multiple obstacles.

**Docker compose versioning problem (moving to stack)**.  

Firstly, the docker compose version that supports `docker stack deploy` is a legacy version of docker, and there is a difference in the features and syntax supported which caused some problems. The `docker stack` does not take `build`, `container_name` and `depend_on` into consideration, and also handles unnamed volumes differently. Therefore, we had to rewrite the compose scripts to make them compatible with docker stack. One of the biggest change that also resulted from this is that from this point on, we had to [build](https://github.com/DevOps-Sad-people/itu-minitwit/issues/207) the configuration files of each service into Docker images, and publish them to our DigitalOcean registry. This came with several complications, such as automatically building images in our workflows during deployment, and ensuring correct versioning/tagging for each image, since publishing all images in every deployment would take a lot of resources and time. This change also solved another one of our problems: previously, we manually copied all configuration files onto the server using `scp`, which made every deployment error prone.

Secondly, the swarm nodes were able to communicate with each other, but self-instantiated virtual networks defined in the docker-compose file did not propagate to worker nodes, leaving application containers unable to contact the database, and prometheus unable to collect monitoring events. To accommodate the issue, we destroyed and redeployed new virtual machines, and this time used the VPC IP address to define the IP address of the manager node. This meant that workers are referring to the manager using the virtual network layer, which solved the communication issue.


### Logging issues

The initial deployment of our logging stack was quite problematic (see [Issue#164](https://github.com/DevOps-Sad-people/itu-minitwit/issues/164) and [Issue#184](https://github.com/DevOps-Sad-people/itu-minitwit/issues/184)), as Elasticsearch turned out to be very resource heavy, consuming almost ~60-80% CPU at times (before introducing logging, it was ~10% at peak load), and also taking all available RAM. We tackled this in two ways:
- We scaled the droplets vertically, giving them more resources, as previously discussed. This was necessary because the stack has larger minimal resource requirements than what we had.
- We introduced Logstash filters, which dramatically decreased the number of fields indexed by Elasticsearch, lowering its resource consumption greatly.

We also encountered another [issue](https://github.com/DevOps-Sad-people/itu-minitwit/issues/224) with Filebeat, after switching to Docker Swarm. We found that one Filebeat instance needs to run on each node, because every instance needs direct access to read the containers' log files. This was solved by introducing global replication for not only the Minitwit application, but for Filebeat as well.


### Large amount of features cloging up in staging (impossible to migrate to production)

Fully implementing new features sometimes took longer than a week. Due to the development workflow described earlier, the staging environment was used as a development/testing environment. This resulted in features being gate keeped by other partially implemented features. Some of the new features also required changing others, such as the migration from docker compose to docker swarm requiring a full rewrite of the docker compose scripts. These made it impossible to migrate the changes to production in time and delayed the release of the full implementation of the logging and monitoring.

## Operation

### Database logical replication resulting in db crash
Migrating from docker compose to the docker swarm included the use of a PostgreSQL feature: logical replication, which allows PostgreSQL instances to live sync data from one running PostgreSQL instance to the other. This feature is typically used to keep a hot stand-in database ready. In our case, it meant we would actively sync data from the active production database, onto the new production database, allowing us to switch from one stack to the other with zero downtime, as the stand-in database would become the new default.

Unfortunately, after switching a few days later, the pub/sub mechanism of logical replication in PostgreSQL accidentally corrupted a tracking file, meaning the database would immediately crash on start. This problem was accomodated by running `pg_resetwal` to reset the corrupted file, and then unsubscriping from the expired subscription. The subscription does not provide any value at this point, as we swapped from the old to the new production machine, and the old one has been turned off.


### Log overflow problem
After quite some time into development, our production droplet became overwhelmed by the large volume of logs being generated by the different containers. This log overflow consumed all available disk space on our droplet, resulting in the droplet becoming inoperable, also shutting down our whole system. We did not notice this issue for a few days as Grafana also shut down, being unable to send alerts to us. After noticing the issue, we were also denied SSH access into the droplet. We had to use DigitalOcean's recovery console to regain access to the server, delete unnecessary log files, and restore normal operation. Learning from this incident, we introduced [log rotation](https://github.com/DevOps-Sad-people/itu-minitwit/issues/224#issuecomment-2844970695) in our docker compose file which limits the maximum number and size of generated log files.


### Backup strategy
Although it's great to solve problems on your own, sometimes others have done a great job already. And this proved to be the case for backing up a Postgres database. Simply adding the `eeshugerman/postgres-backup-s3:15` image to the manager node and configuring environment variables, we successfully [set up](https://github.com/DevOps-Sad-people/itu-minitwit/issues/206) a cron job that automatically backs up daily, and sends the backup to DO's space storage, which is S3 compatible. Using the exact same script, it also includes functions that easily allow restoring from a previous backup. The latter is a crucial step, for when things are burning. The container likewise provides clean-up functionality, such that only 7 days of backups are kept.


## Maintenance
### Upgrading to NGINX, setting up UFW, moving to domain
[Upgrading](https://github.com/DevOps-Sad-people/itu-minitwit/issues/91) to NGINX, we learned multiple things about running a system. First being that having a staging environment to learn how to run commands in the correct order proved great when building a functioning shell script that immediately upgrades the production service. Second, that although we had configured our UFW with all the right ports, actually the service was disabled by default. Only by realizing that the 443 port was open (although not specified) did we realize that UFW needs to be activated. From this we gathered that it is important to double check the firewall and other security measures, to ensure they are configured properly. Luckily, our database was not exposed by PORT from the docker network, and therefore inaccessible, but having full access to other ports may have exposed other vulnerabilities on the machine.

### Simulator IP protection stopped simulator access
[Refactoring](https://github.com/DevOps-Sad-people/itu-minitwit/issues/163) simulator requests to only be accepted from a single IP address helped us prevent other malicious users from interfering with the active simulation requests. However, when the new update was pushed, unfortunately the IP protection feature also protected us from the actual simulation IP. Although this worked perfect locally, moving it onto production showed that the feature declined all simulator api requests. From this we learned about the importance of being able to quickly roll back an update. During this experience, we found that we did not have a previous versioned container ready to roll back to, and instead had to allow all IP's which was possible by passing in `ACCEPTED_IPS=*`, which essentially disabled the whole IP protection.

## Style of work
### Reflection on the workflow

Each Friday after the lectures we met up to have an extensive meeting about the current state of the project. First we shared what features we had worked on the past week, what kind of problems we had faced and how we had solved them. We did this to keep everyone up to date with all the different new technologies and featues implemented. 

Second we discussed the content of the lecture and inspected what new features to implement in the next week. Then we discussed *how* to implement the new features and the pros and cons of the different options. For each task we created a new issue on GitHub.

Third we discussed *when* to implement the new issues. The group members had different schedules and varying capacity due to other commitments such as hand-ins for other courses. We took this into considaration when we delegated the work. We typically worked in three teams:

1. Nicolai
2. Gábor and Zalán
3. Sebastian and Nicklas

These Friday meetings worked very well for us, as we all had a very busy schedule. These meetings allowed us to delegate the work, inspect the progress, adapt the plan and be up to date in terms of the implementation details, while still going in depth into the subjects.
