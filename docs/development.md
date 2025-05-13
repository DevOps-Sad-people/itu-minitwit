# Development

- [Playwright](#Playwright)

## Playwright

### Setting up

You can download a VS Code extension "Playwright Test for VSCode" to help with the test.

1. Install python requirements

```bash
pip install -r requirements.txt
```

2. Install Playwright

```bash
pip install playwright
```

3. Install the browsers

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

