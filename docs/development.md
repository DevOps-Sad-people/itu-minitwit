# Development

- [Playwright](#Playwright)

## Development Worflow

1. Create a new branch from `develop` with the name `<ticket_number>_<new_feature>` or `bugfix/<bug_fix>`
1. Fix the bug or add the new feature
1. Create a Pull Request to `develop`
1. The pull reqeuest is reviewed by minimum 1 other person
1. The pull request is merged to `develop` 

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

