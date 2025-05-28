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
