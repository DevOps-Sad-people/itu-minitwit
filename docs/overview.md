
## Applied strategy for scaling and upgrades.

Scaling up? Scaling up (vertical scaling) more resources 

We started the project with one 1gb node   

Scaling horizontally?
We added more nodes 
Docker 
Manager 

### Upgrade from docker compose to docker stack

We upgraded to use docker compose scripts. 
For the horizontal scaling we had to implement docker stack. 

Docker stack is a way to deploy and manage mulitple docker continers across a Swarm environment - a multi-container application. 

The docker stack deployment features in docker builds on [legacy version of the Compose file format](https://docs.docker.com/reference/compose-file/).

Further there are other differences when using a compose file for a docker stack deployment compared to a docker compose deployment. 

In a docker stack deployment pre-built images are required - where in Docker Compose you can build the images. 

**docker compose vs docker stack fields**

When using `docker stack deploy` some fields in the compose file are ignored:
- `build`
- `container_name`
- `cap_add`
- `depend_on`
- `privileged`

Then some additional fields can be specified when using docker stack
- `deploy` with the subfields
   - `replicas`, `resources`, `placement`, `update_config`
- `mode` (`global` or `replicated`)


The legacy docker compose versioning, the differences in the fields available made it diffucult to transition from `docker compose` to `docker stack deploy`.


### Terraform

