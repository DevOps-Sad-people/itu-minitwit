
## Playwright Testing

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
### Create a new test
1. Create a new file in the `Playwright` folder with the name `test_<new_test>.py`
1. The file should have functions to test the new functionality
1. The function take in the `Page` class from `playwright.sync_api` 
1. The function should have `page.goto("<url_of_page_to_test>")`
1. Then the rest of the function should test the functionality of the page
1. Read the next section to see how to record a test