from playwright.sync_api import Page, expect
from utils import get_random_string


def test_sign_in_empty_db(page: Page) -> None:

    # Arrange
    # Get a random string 
    random_string = get_random_string(10)

    # First create a random user
    # Go to the public page and then click on the sign up link
    page.goto("http://localhost:4567/public")
    page.get_by_role("link", name="sign up").click()

    # Create a random user
    page.locator("input[name=\"username\"]").click()
    page.locator("input[name=\"username\"]").fill(random_string)
    page.locator("input[name=\"username\"]").press("Tab")
    page.locator("input[name=\"email\"]").fill(f"{random_string}@email.com")
    page.locator("input[name=\"email\"]").press("Tab")
    page.locator("input[name=\"password\"]").fill(random_string)
    page.locator("input[name=\"password\"]").press("Tab")
    page.locator("input[name=\"password2\"]").fill(random_string)
    # Submit the form and sign up
    page.get_by_role("button", name="Sign Up").click()

    # Assert that the user was created
    expect(page.get_by_role("listitem")).to_contain_text("You were successfully registered and can login now")
    
    # Now sign in with the user
    page.locator("input[name=\"username\"]").click()
    page.locator("input[name=\"username\"]").fill(random_string)
    page.locator("input[name=\"password\"]").click()
    page.locator("input[name=\"password\"]").fill(random_string)
    
    # Submit the form and sign in
    page.get_by_role("button", name="Sign In").click()
    
    # Assert that the user was signed in
    expect(page.locator("body")).to_contain_text("You were logged in")

