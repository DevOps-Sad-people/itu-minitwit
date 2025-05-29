# System

A description and illustration of the:

## Design and architecture of the _ITU-MiniTwit_ systems

The current achitecture of the minitwit system. The ideal architecture can be found in the appendix. 
![Project architecture](./images/minitwit_terraform_architecture.drawio.png)
The current deployment flow.
![Deployment flow](./images/deployment_flow.drawio.png)


## [Nic] All dependencies of your _ITU-MiniTwit_ systems on all levels of abstraction and development stages. That is, list and briefly describe all technologies and tools you applied and depend on.
### Application
| Tech/Tool | Discription |
| ----| ----- |
| Ruby |  Programming language |
| Sinatra | Lightweight Ruby web framework for building simple web applications |
| Sequal |  Ruby Database ORM |
| pg | Ruby PostgreSQL library  |
| digest |  For md5 and sha2  |
| json | For json manipulation   |
| dotenv | To work with the .env file  |
| rack |  Defines a standard way for Ruby web frameworks and web servers to communicate |
| prometheus/middleware/exporter |  Prometheus Ruby client to expose metrics to Prometheus |
| active_support/time | powerful time-related extensions to `Time` and `Date` |

### Database
|Tech/Tool| Discription|
|----| ----|
| PostgresSQL | The database management system |
| eeshugerman/postgres-backup-s3:15 | To automate PostgreSQL database backups and upload them to  S3 using PostgreSQL |

### Testing, Linting and Static Analysis

| Tech/Tool         | Description |
|-------------------|-------------------------|
| Python            | Programming language |
| requests          | Python library for making HTTP requests|
| Playwright        | End-to-end testing framework for web apps |
| pytest            | Popular Python testing framework for writing simple tests. |
| rspec             | Ruby testing framework focused on behavior-driven development |
| SonarQube         | Static code analysis tool to detect bugs, |
| hadolint/hadolint | Linter for Dockerfiles to catch syntax errors |
| erb_lint          | Linter for ERB (Embedded Ruby) templates  |

### Deployment

| Tech/Tool               | Description  |
|---------------------    |--------------|
| ubuntu                  | Popular open-source Linux distribution  |
| NGINX                   | High-performance web server and reverse proxy server |
| Docker                  | Platform for developing, shipping, and running applications in containers.  |
| GitHub                  | Cloud-based platform for hosting and managing Git repositories.        |
| GitHub Actions          | CI/CD service by GitHub for automating workflows like testing and deployment. |
| GitHub Secrets          | Secure way to store and manage sensitive information (e.g., API keys) in GitHub workflows. |
| Vagrant                 | Tool for managing and provisioning virtual machine environments using simple configuration. |
| Terraform               | Infrastructure as Code (IaC) tool for automating cloud infrastructure provisioning. |
| Digital Ocean           | Cloud service provider offering scalable computing resources and services. |
| DO Container Registry   | Service to store and manage Docker container images.                        |
| DO object Storage (S3)  | Object storage service, similar to AWS S3, for storing files and backups.   |


### Monitoring + Logging
| Tech/Tool     | Description                                                                 |
|---------------|-----------------|
| Elasticsearch | Distributed search and analytics engine used for storing and querying logs, metrics |
| Logstash      | Data processing pipeline tool that collects, transforms, and forwards data to Elasticsearch. |
| Filebeat      | Lightweight shipper for forwarding and centralizing log data to Logstash or Elasticsearch. |
| Kibana        | Data visualization and exploration tool for Elasticsearch, used for dashboards and log analysis. |
| Prometheus    | Open-source monitoring and alerting toolkit designed for reliability and metrics collection. |
| Grafana       | Visualization tool used to create dashboards from time-series data like Prometheus metrics. |




## [Nic] Important interactions of subsystems.
Both the simulator and client contact the same API application, so both sequence diagrams look identical. The following sequence diagram uses the simulator request endpoint `/fllws/[username]` as the baseline. The following sequence diagrams does not take Docker Swarm into account, as the underlying communication is hidden.

![UML Sequence diagram of monitoring and logging](./images/sim-request.jpg)

For monitoring and logging, we have also included a sequence diagram to show how they interact with each other.

![UML Sequence diagram of monitoring and logging](./images/monitor+logging.jpg)


## [G] Describe the current state of your systems, for example using results of static analysis and quality assessments.
At the current state of the project all major functionalities are implemented and out on production with only a few minor issues remaining, which are listed on the Github repository's Issues page [here](https://github.com/DevOps-Sad-people/itu-minitwit/issues). 
   
Throughout development we also used static analysis tools such as SonarQube and CodeClimate to ensure code quality. The quality assessment reported by SonarQube can be seen on the image below:   

![SonarQube report of the project](./images/analysis.png)
   
We managed to avoid/solve *Security* and *Reliablity* issues, and the remaining *Maintainability* issues mainly included "multiple string literals" problems, which we deemed non-crucial. Code duplication was also kept at minimal, coming in at 7.9% for the the entire codebase (*Note: source code provided by the course, such as the flag_tool or the simulator was excluded from the quality assessment*).


## [ALL] MSc students should argue for the choice of technologies and decisions for at least all cases for which we asked you to do so in the tasks at the end of each session.


### Programming language and framework
We considered several programming languages and frameworks for the API application, including C# with Razor-Pages, Ruby with Sinatra, and Go with Gorilla. More in Appendix. 


### Virtualization techniques and deployment targets

### CI/CD system

We have chosen Github actions they offers a free, scalable, and secure CI/CD solution with seamless GitHub integration, customizable YAML workflows, reusable actions, multi-platform support, and efficient automation through parallel execution and event-driven triggers.


### Database
We went with postgres. Both MySQL and postgres are great options for our purpose - familiarity with postgres and open-sourced tech ruled the choice. More in appendix. 

### Testing (Unit, UI, E2E)

**Selenium vs Playwright**

Playwright is a fast, open-source browser automation tool backed by Microsoft that launches browsers quickly, runs tests in parallel, and uses optimized headless mode for faster execution than Selenium. It supports Chromium, Firefox, and WebKit natively, auto-waits for elements to reduce flakiness, and uses a persistent WebSocket connection instead of Selenium’s HTTP-based WebDriver. We tried to implement both Selenium and Playwright. For us it was impossible to get the Selenium to work, we had critical problems with the external browser drivers needed for the Selenium framework to work. Playwright did not need external dirvers since built in protocol clients and was easy to setup and use to develop new UI test. 

**Minitest vs Rspec**

We chose RSpec, as we're prioritizing readable and maintainable technologies. It is also a very popular and large toolkit, which is great for testing!


### Static Analysis + Linting

### Hosting (Digital Ocean)

**Digital Ocean vs AWS/Microsoft Azure**
They both offer rental of VMs. We chose Digital Ocean because of its simplicity and great tooling. Because of the simplicity we can focus on everything else, rather than learning how a complex tool works. Pros and cons found in Appendix. 

### Monitoring + Logging

### Infrastructure as Code (Terraform)

Vagrant for staging and Terraform for production. We chose Terraform for production because it is powerful and flexible, allowing us to manage our infrastructure as code across multiple droplets. Vagrant is used for staging because it provides a simpler setup, allowing us to quickly spin up and tear down instances as needed.


### old 

## Virtualization
- **Docker**
- **Vagrant**

## Change of database

We went with postgres. Both MySQL and postgres are great options for our purpose - familiarity with postgres and open-sourced tech ruled the choice.

## Monitoring
We chose **Prometheus** + **Grafana** for our monitoring stack.

**Prometheus** provides several features which are useful for us:
- centralized, pull-based metric collection
- metrics are time-series based -> can show changes over time
- had ane existing Ruby client library -> easy setup & integration with our system

**Grafana:**
- integrates well with Prometheus
- supports a wide range of metric types
- (relatively) easy to use by writing PromQL queries
- supports alerts (e.g. email)

## Logging
- **ELFK stack - Filebeat + Logstash + Elasticsearch + Kibana**
  - very popular, pretty much industry standard
  - nice interoperability (Kibana is tailored for Elasticsearch)
  - Logstash + Elasticsearch can be very resource-heavy -> Filebeat addresses this with lightweight log collection
- **Grafana + Loki**
  - less resource-heavy
  - could integrate well into our existing Grafana service
  - less popular choice

We chose the ELFK stack mainly because it's the most popular choice, and we wanted to get familiar with it.
