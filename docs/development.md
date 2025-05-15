# Development

- [Local development](#How-to-run-locally)
- [Playwright](#Playwright)

## How to run locally

To start up all docker services:

`docker compose -f docker-compose.dev.yml up -d`

After this, the minitwit application will be avaible at http://localhost:4567/.

To run a specific service:

`docker compose -f docker-compose.dev.yml up <service_name> -d`

To run the tests:

`docker compose -f docker-compose.testing.yml up --abort-on-container-exit --exit-code-from test`

To stop and delete running containers:

`docker compose -f docker-compose.dev.yml down`

To stop and delete a specific container:

`docker compose -f docker-compose.dev.yml down <service_name>`

To clean up volumes afterwards: (***WARNING:*** deletes all persisted project data)

`docker compose -f docker-compose.dev.yml down --volumes`

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

