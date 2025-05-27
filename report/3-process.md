# Process

This perspective should clarify how code or other artifacts come from idea into the running system and everything that happens on the way.

In particular, the following descriptions should be included:

## [Nic] A complete description of stages and tools included in the CI/CD chains, including deployment and release of your systems.
In the following section, we will discuss the CI/CD pipeline of our system, and for this, we discuss two key branches: `main` and `develop`. The `main` branch includes the code running on our production environment, and `develop` branch includes the code running on our staging environment. For the sake of communication, we will simply address these branches by `production` and `staging`.

We use GitHub for handling our repository and tracking the process with their issue system. We use a branching strategy, where features written in issues are worked on in `feature`-branches. Once ready, they are then merged into `staging` and then into `production`. This enables us to test and deploy the feature before production, at the cost of slightly longer delivery times. This means that for features to make it through to production, it includes three phases:

1. We work on the issue using a `feature`-branch. Developers work on and finalize the feature on this branch.
2. Once ready, a pull-request is created to merge the `feature`-branch into `staging`, where tests, linting, static code analysis and a fellow team member, must pass or approve the request, before being able to merge it into staging.
3. Once deployed to the staging environment, if the staging environment sees no failures and passes a manual test, a pull-request into `production` is made. Once approved by tests, linting, static code analysis and a fellow team member, the feature is pushed into main.

### Automated Testing and Quality Gates

Pull-requests as well as pushing to staging and production, include several tests that are performed using workflows that trigger a GitHub action, which builds a Docker container with which these tests can be performed. On top of the web API container, an associated PostgreSQL database is instantiated, to perform E2E and simulation tests.

- Unit tests are performed using Ruby Rack
- E2E tests are performed using Playwright
- Simulation tests are performed by instantiating a new environment, and using Python to perform requests
- Static code analysis using SonarQube, which requires ≤3.0% code duplication in the Ruby application.

GitHub branch protection rules ensure that developers follow this workflow. Concretely it prevents users from merging directly into the `staging` and `production` branch.

On top of the above, Ruby and Docker code is formatted and linted on push to any branch. This is done using the GitHub action modules `standardrb/standard-ruby-action@v1` and `hadolint/hadolint` respectively.

### Build and Deployment Process

We deploy using GitHub Actions, which builds containers and uploads them to Digital Ocean's container registry. We also upload a new version of the Ruby application, and if there are updates to the configs for either our monitoring or logging stack, we also push a new version of that. If tests pass, then we automatically continue to deploy. Currently we differentiate between containers designated for the staging and production environment by assigning them such a tag.

The deployment process involves SSH'ing into the manager node of the Docker Swarm, that is running as droplets (virtual machines) on Digital Ocean, and running a deploy.sh script, which simply pulls the newest version of the stack from the container registry.

On pushes to main, we automatically create a new release, which includes bumping the application with a new minor-update, meaning 1.0.0 turns into 1.1.0. If we wish to introduce a patch or major update, we can specify in the commit message.

We orchestrate the containers using Docker Swarm, and given the size of our application, we currently follow the direct deployment rollout strategy, where we simply push a new version to all worker nodes at once. This is a point for improvement.

### Environment Management and Infrastructure

We have manually set up instances using Digital Ocean's interface, but have prepared a Terraform script for setting up a new environment in the future. For artifact management, we use Digital Ocean's container registry, where we only differentiate between container versions using staging and production tags.

To distribute secrets that GitHub Actions can access, we set up GitHub secrets to keep an access key to Digital Ocean on which we deploy our application.

### Rollback Strategy

To roll back, it would require manually SSH'ing into the server and modifying the compose script to depend on a specific container in Digital Ocean's registry. This is definitely a weak point, making it time consuming to rollback and represents an area for future improvement.

### Monitoring and Observability

Once the feature is successfully integrated into the production codebase, we use Prometheus and Grafana to monitor the application, ensuring that the feature introduces no error, and that operation levels remain the same. In case of noticeable changes, we use Kibana to navigate logs to help diagnose the problem. Kibana queries Elasticsearch, which receives logs from Logstash, who in turn accesses log-files using Filebeat.

### Choice of Architecture & Technologies
We chose to have a staging environment, as it helped us understand how to properly integrate features and architecture changes before proceeding to do so on production. Given this projects work included a lot of architecture change and adding new technologies, this helped us immensely in preventing down-time by ensuring that the config worked on a deployed environment.

We chose Github as it is a well establish standard for git and code control. On top, it granted us access to Github Actions, which is a great tool for building workflows to establish a CI/CD pipeline. Github Action was a great choice, as it integrated well into the Github environment.   

Using Digital Oceans container registry became our choice given it's integration with the DigitalOcean platform. Only after using it, did we realize that the biggest upsides are primary for users of digital oceans other deployment tools, that are not running on rented VMs. Given the price of DO's container registry, we would most likely migrate to Docker Hub, if the project had continued.

We chose SonarQube for static analysis as it gave us an ability to understand code duplication while being simple to integrate into our CD/CI pipeline.



## [Z/G] How do you monitor your systems and what precisely do you monitor?



## [Z/G]  What do you log in your systems and how do you aggregate logs?



## [Nic] Brief results of the security assessment and brief description of how did you harden the security of your system based on the analysis.
By running through the [OWASP Top 10 list](https://owasp.org/www-project-top-ten/) on security assessment, we have done the following analysis:

- A01:2021-Broken Access Control
In the system only two levels of access control exist in the system. Either you are a user, who can post, follow and unfollow, or you access as a public user. For user-specific endpoints, we have not found any vulnerabilities. CORS settings however, allow anyone to access the API. This misconfiguration allows malicious websites to make authenticated requests to the API on behalf of logged-in users.

- A02:2021-Cryptographic
We've upgraded from HTTP to HTTPS, but still expose the port of the application, meaning IP:PORT still gives users access to the service in non-encrypted ways, such that network eavesdroppers can capture username and passwords. The hashing algorithm has been upgraded from MD5 to SHA256, but unfortunately without salting, allowing attackers who gain access to the database to easily crack passwords with rainbow tables or brute force attacks. Lastly, the simulator protection-key is hard-coded which means anyone with access to the public github repo, can essentially bypass that security measure.

- A03:2021-Injection
We use the ORM Ruby Sequel, which includes sanitization of input before constructing SQL statements. Developers can create raw SQL statements, but we have opted not to do this given the impracticality and security risks.

A04:2021-Insecure Design
Given the tiny feature set, we could not find anything particularly noteworthy about the design.

A05:2021-Security Misconfiguration
After experiencing a ransomware attack, requiring bitcoin for our data, we closed ports and changed the default password to prevent future attacks. Similarly, we discovered that `ufw` was disabled by the end of the course, which exposes all services to the web. Lastly, we are aware that CORS settings are overly permissive as elaborated in A01.

A06:2021-Vulnerable and Outdated Components
Our system has very weak password checking, which allow users to create easily hackable accounts. Simultaneously, weak email validation and not sending a confirmation email makes it particularly easy for bots to create users. In fact, 99.9% of our activity is from a single bot.

On the developers side, we did not require 2FA to log into DigitalOcean, bringing our level of security down to the weakest login-type of the five team members. And technically, Dependabot has been suggesting a Ruby update from `3.3.7` to `3.4.4`, which have been postponed multiple times.

A08:2021-Software and Data Integrity
We have not been able to identify any issues regarding this.

A09:2021-Security Logging and Monitoring Failures
We experienced a log overflow causing our production service to fail. This failure did not cause any warnings, causing three days of downtime for our application. We will elaobrate on how we fixed this when reflecting on system operation.

A10:2021-Server-Side Request Forgery
We have not been able to identify any issues regarding this.


## [Seb/Nick] Applied strategy for scaling and upgrades.



## [Nic] In case you have used AI-assistants during your project briefly explain which system(s) you used during the project and reflect how it supported or hindered your process.
This project included the use of both chatbots and in-editor help using copilot. These were provided by OpenAI and Anthrophic.

Copilot increased speed by solving minor problems through it's line-for-line help. To increase the precision, prompt-like comments would be added prior to the line of interest, or specific prompts would be used to concretely specify the desired change.

Chatbots on the other hand involved four primary types of prompts:
- Elaboration: Please explain X technology
- Comparing: What is the difference between X and Y technology
- Creation: I want to X
- Solving: I want X, but instead Y happens.

Elaboration and comparison were primarily used at the planning stage of implementing new technologies, or for developers unfamiliar with existing technologies already implemented.

Creation is used throughout the implementation of technologies or features, but the scale of the issues attempting to address diminishes over time, as the feature or technology becomes more intergrated into the system, and required changes are smaller.
As more code is added to the codebase, solving unwanted behavior becomes more important, and makes out large parts of prompts.

Additional reflection on use of chatbots, we found that Claude 3.7 Sonnet provided better code-based responses as well as understanding misconfigurations and bugs. It gives detailed descriptions of different variables and potential flaws in the code and configs. This is measured against ChatGPT o1.
