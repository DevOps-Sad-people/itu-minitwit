# Development


## Playwright

### Setting up

You can download a VS Code extension "Playwright Test for VSCode" to help with the test.

1. Install python requirements

```bash
pip install -r requirements.txt
```

### How to run
How to run all test locally - this will find the test automatically

```bash
pytest
```

if you want to see the test you can run
```bash
pytest --browser chromium --headed --slowmo 200
```

if you want to only run ONE file

```bash
pytest Playwright/test_signup.py  --browser chrome --headed --slowmo 200
```

### How to record and generate

You can record test by running this command
```bash
playwright codegen http://localhost:4567/public
```

Then you can use the recorder tool to create the test and copy it to the python file and function you have created.