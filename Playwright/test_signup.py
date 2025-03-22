from playwright.sync_api import Page, expect
from utils import get_random_string

def test_sign_up_empty_db(page: Page) -> None:
    
    # Arrange
    # Get a random string
    random_string = get_random_string(10)
    
    # Go to the public page and assert the application
    # Then click on the sign up link
    page.goto("http://localhost:4567/public")

    # There can be messages so we don't assert this 
    # expect(page.get_by_role("emphasis")).to_contain_text("There's no message so far.")
    
    expect(page.get_by_role("heading")).to_contain_text("MiniTwit")
    expect(page.locator("body")).to_contain_text("MiniTwit — A Ruby Sinatra Application")
    expect(page.locator("body")).to_contain_text("sign in")
    expect(page.locator("body")).to_contain_text("sign up")
    expect(page.get_by_text("MiniTwit — A Ruby Sinatra")).to_be_visible()
    expect(page.locator("body")).to_contain_text("Page 1 of 1")

    # Click on the sign up link and fill out the form
    page.get_by_role("link", name="sign up").click()
    page.locator("input[name=\"username\"]").click()
    page.locator("input[name=\"username\"]").fill(random_string)
    page.locator("input[name=\"username\"]").press("Tab")
    page.locator("input[name=\"email\"]").fill(f"{random_string}@a.dk")
    page.locator("input[name=\"email\"]").press("Tab")
    page.locator("input[name=\"password\"]").fill(random_string)
    page.locator("input[name=\"password\"]").press("Tab")
    page.locator("input[name=\"password2\"]").fill(random_string)
    
    # Submit the form and sign up
    expect(page.get_by_role("button", name="Sign Up")).to_be_visible()
    expect(page.get_by_role("button")).to_contain_text("Sign Up")
    page.get_by_role("button", name="Sign Up").click()
    
    # Assert that the user was created
    expect(page.get_by_role("listitem")).to_contain_text("You were successfully registered and can login now")

# 
def test_sign_up_existing_user_expect_error_on_page(page: Page) -> None:
    
    # Arrange
    random_string = get_random_string(10)

    # Go to the public page and click on the sign up link
    page.goto("http://localhost:4567/public")
    expect(page.locator("body")).to_contain_text("Page 1 of 1")
    expect(page.locator("body")).to_contain_text("MiniTwit — A Ruby Sinatra Application")
    page.get_by_role("link", name="sign up").click()
    
    # Assert the sign up form
    expect(page.get_by_role("button")).to_contain_text("Sign Up")
    expect(page.get_by_role("button", name="Sign Up")).to_be_visible()
    
    # Fill out the form and sign up
    page.locator("input[name=\"username\"]").click()
    page.locator("input[name=\"username\"]").fill(random_string)
    page.locator("input[name=\"email\"]").click()
    page.locator("input[name=\"email\"]").fill(f"{random_string}@email.com")
    page.locator("input[name=\"email\"]").press("Tab")
    page.locator("input[name=\"password\"]").fill("1")
    page.locator("input[name=\"password\"]").press("Tab")
    page.locator("input[name=\"password2\"]").fill("1")
    page.get_by_role("button", name="Sign Up").click()
    
    # Assert that the user was created
    expect(page.get_by_role("listitem")).to_contain_text("You were successfully registered and can login now")
    page.get_by_role("link", name="sign up").click()
    expect(page.get_by_role("button", name="Sign Up")).to_be_visible()
    expect(page.get_by_role("button")).to_contain_text("Sign Up")

    # Try to create the same user again
    # Fill out the form with the same username 
    page.locator("input[name=\"username\"]").click()
    page.locator("input[name=\"username\"]").fill(random_string)
    page.locator("input[name=\"username\"]").press("Tab")
    page.locator("input[name=\"email\"]").fill(f"{random_string}@email.com")
    page.locator("input[name=\"email\"]").press("Tab")
    page.locator("input[name=\"password\"]").fill("1")
    page.locator("input[name=\"password\"]").press("Tab")
    page.locator("input[name=\"password2\"]").fill("1")
    
    # Try to submit the form and sign up - expect an error to shown on the page
    page.get_by_role("button", name="Sign Up").click()
    expect(page.locator("body")).to_contain_text("Error: The username is already taken")
