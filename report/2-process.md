<a name="section-process"></a>

# Process

This perspective tries to clarify how code or other artifacts come from idea into the running system.

## CI/CD chain (tools)

Our CI/CD pipeline uses two main branches: `main` (production) and `develop` (staging), with GitHub managing the repository and issues. Features are developed in `feature`-branches, merged into staging for testing and review, and then into production after passing all checks. This process involves three phases: development on a feature branch, review and testing in staging, and final approval and deployment to production. More info in Appendix. 

### Automated Testing and Quality Gates

All pull requests and pushes to staging and production trigger GitHub Actions workflows that build a Docker container with a PostgreSQL database for testing. The pipeline includes unit tests (Ruby Rack), E2E tests (Playwright), simulation tests (Python), and static code analysis (SonarQube with ≤3% Ruby code duplication). Branch protection rules enforce this process, and Ruby and Docker code are auto-linted on every push using `standardrb` and `hadolint`. More in appendix. 

### Build and Deployment Process

We deploy using GitHub Actions, which builds containers and uploads them to Digital Ocean's container registry. We also upload a new version of the Ruby application, and if there are updates (detected by `git diff`) to the configs for either our monitoring or logging stack, we also push a new version of that. If tests pass, then we automatically continue to deploy. Currently we differentiate between containers designated for the staging and production environment by assigning them such a tag.

The deployment process involves SSH'ing into the manager node of the Docker Swarm, that is running as droplets (virtual machines) on Digital Ocean, and running a deploy.sh script, which simply pulls the newest version of the stack from the container registry.

On pushes to main, we automatically create a new release, which includes bumping the application with a new minor-update, meaning 1.0.0 turns into 1.1.0. If we wish to introduce a patch or major update (or do no release at all), we can specify in the commit message.

We orchestrate the containers using Docker Swarm, and given the size of our application, we currently follow the direct deployment rollout strategy, where we simply push a new version to all worker nodes at once. This is a point for improvement.

### Environment Management and Infrastructure

We use Terraform scripts for setting up our production environment. For artifact management, we use Digital Ocean's container registry, where we differentiate between container versions using staging and production tags.

To distribute secrets that GitHub Actions can access, we set up GitHub Secrets to keep an access key to Digital Ocean on which we deploy our application.

### Rollback Strategy

To roll back, it would require manually SSH'ing into the server and modifying the compose script to depend on a specific container in Digital Ocean's registry. This is definitely a weak point, making it time consuming to rollback and represents an area for future improvement.

### Monitoring and Observability

Once the feature is successfully integrated into the production codebase, we use Prometheus and Grafana to monitor the application, ensuring that the feature introduces no error, and that operation levels remain the same. In case of noticeable changes, we use Kibana to navigate logs to help diagnose the problem. Kibana queries Elasticsearch, which receives logs from Logstash, who in turn accesses log-files using Filebeat.

### Choice of Architecture
We chose to have a staging environment, as it helped us understand how to properly integrate features and architecture changes before proceeding to do so on production. Given this projects work included a lot of architecture change and adding new technologies, this helped us immensely in preventing down-time by ensuring that the config worked on a deployed environment.


## Monitoring

Monitoring is configured in our system using Prometheus and Grafana. Prometheus handles time-series based raw metric collection, Grafana handles metric visualization.

### How it works in our system

Our Minitwit application uses an existing Ruby client library of Prometheus, and exposes raw metrics on the `/metrics` endpoint. The Prometheus service periodically scrapes the data from this endpoint of the application. In Grafana, these collected metrics are visualized using highly customizable dashboard panels. In each panel, metrics from Prometheus are queried at regular intervals using PromQL queries. We also set up email alerting for certain panels, this way we can be notified when certain conditions, thresholds etc. are met.

### Panels configured on our Grafana dashboard

- **HTTP response count by status codes:** Time-series. Shows the number of HTTP responses during the last minute at any given point of the time range, grouped by status codes.
- **HTTP error response count:** Time-series. Shows the number of HTTP client- and server-side error responses during the last minute at any given point of the time range. Email alerting is also set up for this panel, when the server-side (5XX) error count during the last minute hits a certain threshold.
- **Latency percentiles:** Time-series. Shows the median, 95th and 99th percentiles of latency (request duration) in milliseconds at any given point of the time range.
- **Average latency:** Gauge. Shows the average latency in milliseconds over the given time range.
- **Total registered users:** Stat. Shows the total number of registered users in the Minitwit application.

As seen in the list above, aside from the *Total registered users* panel, we mainly do infrastructure monitoring in our system. We also planned to include more meaningful application-specific monitoring too such as the number of new users/new posts made in the last X minutes; due to time constraints, however, we did not implement these.


## Logging

Logging is configured in our system using the ELFK stack: Elasticsearch, Logstash, Filebeat and Kibana.

### How it works in our system and log aggregation

First, Filebeat handles log shipping by reading and collecting logs from each of our Docker containers' log files. These logs are then forwarded to Logstash, which processes and transforms the log data as needed. Logstash then sends the processed logs to Elasticsearch where they are indexed and stored for efficient querying. Finally, the aggregated logs are visualized using Kibana.

The reason we also used Filebeat for log shipping is because it is much more lightweight than Logstash. Traditionally, Logstash is the log aggregator which collects, transforms and forwards logs for further processing, but since we have multiple physical nodes in our system, each node would require one Logstash instance running on them. Instead, each node has a Filebeat instance running which handles log shipping for the containers running on that node.

### What we log in our system

Filebeat forwards all logs, from all Docker containers in the system. In Logstash, we filter based on the logging levels (filtering/parsing is specific to each service's logging format). We try to parse each log record to extract the logging level; if the parsing was successful, all *DEBUG*- and *INFO*-level messages are excluded, everything else is forwarded to Elasticsearch for indexing. Additionally, Logstash also drops many unneeded fields in each log record, so that the number of indexed fields will stay relatively small.


## Security Assessment
By running through the [OWASP Top 10 list](https://owasp.org/www-project-top-ten/) on security assessment, we have done the following analysis:

- **A01:2021-Broken Access Control**
The system has two levels of access control, a user or public user.
We have found no vulnerabilities for user-specifc endpoints. 
But anyone can access the API this allows malicious websites to make authenticated requests to the API on behalf of logged-in users.

- **A02:2021-Cryptographic**
Upgraded to HTTPS, but still exposes its port over HTTP, leaving credentials vulnerable to interception.
Passwords are hashed with SHA256 but without salting, and the hard-coded simulator protection key in the public GitHub repo undermines its security.

- **A03:2021-Injection**
We use the ORM Ruby Sequel, which includes sanitization of input before constructing SQL statements. Developers can create raw SQL statements, but we have opted not to do this given the impracticality and security risks.

- **A05:2021-Security Misconfiguration**
Following a ransomware attack demanding bitcoin, we closed ports and changed default passwords to improve security. 
However, `ufw` was later found disabled, exposing all services, and overly permissive CORS settings remain a known vulnerability(explained in A01).

- **A06:2021-Vulnerable and Outdated Components**

- Our system allows weak passwords and lacks proper email validation or confirmation, making it easy for bots to create accounts one of which accounts for 99.9% of activity. 
On the developer side, 2FA is not enforced for DigitalOcean access, and important security updates, like Ruby 3.3.7 to 3.4.4, have been repeatedly postponed.

- **A09:2021-Security Logging and Monitoring Failures**
We experienced a log overflow causing our production service to fail. This failure did not cause any warnings, causing three days of downtime for our application. We will elaborate on how we fixed this when reflecting on system operation.

- **A04:2021-Insecure Design, A08:2021-Software and Data Integrity and A10:2021-Server-Side Request Forgery**
We have not been able to identify any issues regarding this.


## Applied strategy for scaling and upgrades.

We have used both horizontal and vertical scaling. 

For the logging and monitoring it was nessesary to scale vertical where we scaled from 1 CPU, 1GB RAM (s-1vcpu-1gb) to 2 CPU, 4GB RAM (s-2vcpu-4gb) to handle the workload associated with monitoring and logging.

We increased the number of node/droplets from 1 to 4 to increase availability when we upgraded from docker compose to docker swarm with a docker stack deployment containing multiple replicas of the minitwit application.

To handle higher user load we first switched from SQLite to PostgreSQL to get a more reliable database. After that we also indexed the database to ensure efficient data access.  

## Use of AI

This project used both Copilot and chatbots (from OpenAI and Anthropic) to support development—Copilot for line-by-line code help, and chatbots for elaboration, comparison, creation, and problem-solving prompts. Claude 3.7 Sonnet outperformed ChatGPT o1 in understanding code, configs, and bugs, offering more detailed and accurate responses.

For full description read Appendix.
