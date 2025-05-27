# Development

- [Development Workflow](#Development%20Workflow)
- [Playwright](#Playwright)

## Development Workflow

### Development Environment

When developing new features you branch off `develop` then implement the changes and test them **locally** via the local docker development environment `dovker-compose.dev.yml`. Then changes are pushed to a remote branch so another person can continue working on the changes. When the feature/tasks is completed a pull request is created. When the changes are approved they merge into `develop` and trigger a new deployment to the staging environment. If the changes work in the staging environment a pull request from `develop` into `main` can be created. Once the pull request is approved a new release and deployment to production is triggered.   

### Repo settings

We have setup branch protection to merge into `main` and `develop` 
1. Merge changes through pull request
1. At least one developer has to approve the changes
1. Workflows and test have to pass LINK TO TESTS

This ensures that all changes to the protected branches have been approved and tested.  


### Ways of Working 


Implementing new features

We met up every friday to first present what we each had worked on the last weeks. If one of us had problems or question we would discuss them here. Then plan how to implement the next weeks features.   

We typically worked in three teams
1. Nicolaj
1. Gabor and Zalan
1. Sebastian and Nicklas

## Playwright

### Setting up

You can download a VS Code extension "Playwright Test for VSCode" to help with the test.

1. Install python requirements

```bash
pip install -r requirements.txt
```

2. Install Playwright  
If you are having problems with the installation of playwright you can try to install it manually.
 
```bash
pip install playwright
```

3. Install the browsers  
Once you have install playwright you have to install the browsers if you want to run playwright locally 

```bash
playwright install
```

### How to record and generate

You can start the application with the following command
```bash
docker compose -f docker-compose.dev.yml run --rm --service-ports web bash
```



Open a new terminal and enter the following to record a new test:
```bash
playwright codegen http://localhost:4567/public
```

Then you can use the recorder tool to create the test and copy it to the python file `test_<new_test>.py` and function you have created.

