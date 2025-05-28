### [Seb/Nick] Repo settings. Workflows on merge. Require 1 team member on pull requests.

This section is also described in the Process Section

To support and enforce the development workflow of new features as explained in [Process Section](3-process.md) we have setup branch protection rules via Github. For the `main` and `develop` branch the rules are:  
 
1. No direct merge into protected branch.
2. Changes must be approved by at least team member
3. Workflows and test must pass

This ensures that all changes to the protected branches have been approved and tested.


### [Seb/Nick] Development environemnt: local => branch => staging => production

As explain in the [Proceess section](3-process.md) we wen developing a new fea

When developing new features you branch off `develop` then implement the changes and test them **locally** via the local docker development environment `dovker-compose.dev.yml`. Then changes are pushed to a remote branch so another person can continue working on the changes. When the feature/tasks is completed a pull request is created. When the changes are approved they merge into `develop` and trigger a new deployment to the staging environment. If the changes work in the staging environment a pull request from `develop` into `main` can be created. Once the pull request is approved a new release and deployment to production is triggered.  


### GitHub Actions as choice 

- Seamless integration into github
- Cost-Effective: It is free for open source project (3000 min pr month)
- Extensive Marketplace and Reusable Workflows
- Pre-Built Actions
- Reusable Workflows
- Scalability and Flexibility
- Supports Multiple Runners: Linux, macOS, and Windows
- Highly Customizable Workflows: You can define the workflows in YAML files
- Built-in Security Features
- GitHub Actions provides secrets management, role-based access control
- Parallel Execution: Supports matrix builds and parallel jobs, reducing build and deployment time
- Tight GitHub Integration: Workflows can trigger on pull requests, pushes, issue comments, and other GitHub events, enabling efficient automation.