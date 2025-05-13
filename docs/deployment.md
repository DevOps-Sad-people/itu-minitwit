# Deployment


## Deployment Workflows (GitHub Actions)

### Workflows on Pull Requests

We run the end-to-end-tests in `E2E-on-reqeust.yml`, the simulator test and ruby unit tests `test-on-request.yml` on every pull requests. This is to ensure that the code is tested working before it is merged into the `develop` and `main` branch.

We also run the `lint-on-push.yml` workflow, in this workflow we run:
- A standard Ruby linter and formatter
- An ERB file linter
- A Dockerfile linter

To ensure that the code is linted before it is merged the changes into `main` and `develop`.


### Deployment to Staging 
 
1. build-minitwit
1. test
1. build-images
1. deploy to staging


### Deployment to Production

1. build-minitwit
1. test
1. build-images
1. deploy to production
1. tag_and_release
