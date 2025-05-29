# Workflows (GitHub Actions)

The workflows are located in the `.github/workflows` folder

## Deployment Workflows 

We have two different deployment workflows, the deployment to production and deployment to staging workflow. 

### Deployment to Production

`deployment-to-production.yml` 

This workflow is triggered on merge to main and deploys the application to the production environment. It builds the Docker images, pushes them to the container registry on DO, and deploys them to the production servers.
It also runs the unit and E2E tests to validate the artifact before deployment.
A tag is created for the release version, which is determined by the contents of the commit messages.

### Deployment to Staging

`deployment-to-staging.yml`   
This workflow is triggered on merge to develo and deploys the application to the production environment. It builds the Docker images, pushes them to the container registry on DO, and deploys them to the staging server.
It also runs the unit and E2E tests to validate the artifact before deployment.


## Testing Workflows

`E2E-on-request.yml`
This workflow is trigged on pull request and runs on deployment workflow. The end to end tests are located in the `Playwright` implemented with Playwright. On how to develop test go to [Testing](testing.md).   

`test-on-request.yml`
The test on request is trigged on a pull request. This workflow contains the unit test and simulator tests.
The simulator test spins up the application and makes request for the endpoints with data from `simulator/minitwit_scenario.csv`


## Generate report Worflow

We have a workflow for generating the report `generate-report.yml`. 
This workflow is trigged on merge to main and generate the `report.pdf` from the markdown files in `report/` folder.
The file `report.pdf` is placed in `report/build/` folder.
 