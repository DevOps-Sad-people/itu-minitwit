# UI-Testing

## Selenium vs Playwright


**Selenium**

Architecture: 
1. Selenium use a language specific client library 
1. WebDriver API
1. Browser Drivers - these are executatbles that act as a middle layer between Selenium and the browser. 
   - Recieve HTTP requests from the Selenium client
   - Translate them into native browser commands (click, navigate, input)
1. Browser
   -  Receives commands from the driver.
   - Executes actions (e.g., loading a page, clicking a button).
   - Returns the result/status back through the driver to the client.


Selenium supports Ruby 
First we tried to implement Selenium but the webdrivers did not work. 


**Playwright**


Architecture: Playwright uses a WebSocket connection rather than the WebDriver API and HTTP. 

Playwright works natively with Chromium, Firefox, and WebKit (Safari engine) out of the box

Auto-waiting for elements prevents flaky tests, whereas Selenium often requires explicit waits

The webSochet stays open for the duration of the test, so everything is sent on one connection. 

This is one reason why Playwright’s execution speeds tend to be faster.

History: Playwright is fairly new to the automation scene. It is faster than Selenium and has capabilities that Selenium lacks, but it does not yet have as broad a range of support for browsers/languages or community support. It is open source and [backed by Microsoft](https://github.com/microsoft/playwright).



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

# Simulator Tests