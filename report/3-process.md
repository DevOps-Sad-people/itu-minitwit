# Process

This perspective should clarify how code or other artifacts come from idea into the running system and everything that happens on the way.

In particular, the following descriptions should be included:

## [Nic] A complete description of stages and tools included in the CI/CD chains, including deployment and release of your systems.

1. Source Code Management
We use Github for handling our repository and tracking process with their issue system. We use a branching strategy, where features written in issues are created in `feature`-branches, which are then merged into `staging` and then into `main`. This enables us to test and deploy the feature before production, at the cost of slightly longer delivery times. Before being able to merge into staging and main, code needs to pass all unit, e2e and simulation tests, check Sonar Cubes quality gate, and lastly be approved by another member of the team.

1. Continuous Integration
On push to staging and main, we built and test using Github Actions. 

Build tools & environments (e.g., Docker, Make, Gradle)

Automated tests (unit, integration, linting)

Test orchestration tools (e.g., Jest, Pytest, Mocha, Cypress)

3. Artifact Management
Build artifacts (e.g., JARs, Docker images, binaries)

Artifact storage (e.g., Nexus, JFrog Artifactory, GitHub Packages)

4. Continuous Delivery
Staging environments

Deployment automation tools (e.g., GitHub Actions, GitLab CI, Jenkins, CircleCI)

Infrastructure as Code (e.g., Terraform, Pulumi, Ansible)

5. Continuous Deployment
Rollout strategy (e.g., canary, blue/green, rolling)

Orchestration platform (e.g., Kubernetes, ECS, Nomad)

Deployment verification (e.g., smoke tests, health checks)

6. Release Management
Versioning strategy (e.g., SemVer)

Release approval workflows

Feature flagging (e.g., LaunchDarkly, Unleash)

Changelog generation

7. Monitoring & Feedback
Logging and error tracking (e.g., ELK, Sentry, Datadog)

Metrics & dashboards (e.g., Prometheus, Grafana)

Alerting setup (e.g., PagerDuty, Opsgenie)

8. Security & Compliance
Static and dynamic code analysis tools (e.g., SonarQube, Snyk, CodeQL)

Secrets management (e.g., HashiCorp Vault, AWS Secrets Manager)

Policy enforcement (e.g., OPA, GitHub branch protection rules)

- Github Issues
- Local branch
- 


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
