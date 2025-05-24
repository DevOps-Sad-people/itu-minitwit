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

   ### [Nic] TLS - 2FA - Port forwarding - DB encryption - ORM 

https://claude.ai/chat/0b811d0e-7c05-4aca-9bb0-e099e4d4bcd5

By running through the [OWASP Top 10 list](https://owasp.org/www-project-top-ten/) on security assessment, we have done the following analysis:
- A01:2021-Broken Access Control
After assessing url endpoints, no evident broken control access is present. Only thing that we have not adjusted for is CORS settings, which 

- A02:2021-Cryptographic
We've upgraded from HTTP to HTTPS, but still expose the port of the application, meaning IP:PORT still gives users access to the service in non-encrypted ways, such that network eavesdroppers can capture username and passwords. The hashing algorithm has been upgraded from MD5 to SHA256, but unfortunately without salting, allowing attackers who gain access to the database to easily crack passwords with rainbow tables or brute force attacks. Lastly, the simulator protection-key is hard-coded which means anyone with access to the public github repo, can essentially bypass that security measure.

- A03:2021-Injection
We use the ORM Ruby Sequel, which includes sanitization of input before constructing SQL statements. Developers can create raw SQL statements, but we have opted not to do this given the impracticality and security risks.


F2A on Digital Ocean & Cloudflare

A04:2021-Insecure Design is a new category for 2021, with a focus on risks related to design flaws. If we genuinely want to “move left” as an industry, it calls for more use of threat modeling, secure design patterns and principles, and reference architectures.




A05:2021-Security Misconfiguration moves up from #6 in the previous edition; 90% of applications were tested for some form of misconfiguration. With more shifts into highly configurable software, it’s not surprising to see this category move up. The former category for XML External Entities (XXE) is now part of this category.
A06:2021-Vulnerable and Outdated Components was previously titled Using Components with Known Vulnerabilities and is #2 in the Top 10 community survey, but also had enough data to make the Top 10 via data analysis. This category moves up from #9 in 2017 and is a known issue that we struggle to test and assess risk. It is the only category not to have any Common Vulnerability and Exposures (CVEs) mapped to the included CWEs, so a default exploit and impact weights of 5.0 are factored into their scores.
A07:2021-Identification and Authentication Failures was previously Broken Authentication and is sliding down from the second position, and now includes CWEs that are more related to identification failures. This category is still an integral part of the Top 10, but the increased availability of standardized frameworks seems to be helping.
A08:2021-Software and Data Integrity Failures is a new category for 2021, focusing on making assumptions related to software updates, critical data, and CI/CD pipelines without verifying integrity. One of the highest weighted impacts from Common Vulnerability and Exposures/Common Vulnerability Scoring System (CVE/CVSS) data mapped to the 10 CWEs in this category. Insecure Deserialization from 2017 is now a part of this larger category.
A09:2021-Security Logging and Monitoring Failures was previously Insufficient Logging & Monitoring and is added from the industry survey (#3), moving up from #10 previously. This category is expanded to include more types of failures, is challenging to test for, and isn’t well represented in the CVE/CVSS data. However, failures in this category can directly impact visibility, incident alerting, and forensics.
A10:2021-Server-Side Request Forgery is added from the Top 10 community survey (#1). The data shows a relatively low incidence rate with above average testing coverage, along with above-average ratings for Exploit and Impact potential. This category represents the scenario where the security community members are telling us this is important, even though it’s not illustrated in the data at this time








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
