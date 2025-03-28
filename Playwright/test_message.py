from playwright.sync_api import Page, expect
from utils import get_random_string


def test_send_message(page: Page) -> None:
    
    # Arrange
    random_string = get_random_string(10)
    
    # Go to the public page and assert the application
    page.goto("http://localhost:4567/public")
    expect(page.locator("body")).to_contain_text("MiniTwit — A Ruby Sinatra Application")
    
    
    expect(page.locator("body")).to_contain_text("Page 1 of 1")
    # expect(page.get_by_role("emphasis")).to_contain_text("There's no message so far.")
   
    # Click on the sign up link and fill out the form
    page.get_by_role("link", name="sign up").click()
    page.locator("input[name=\"username\"]").click()
    page.locator("input[name=\"username\"]").fill(random_string)
    page.locator("input[name=\"username\"]").press("Tab")
    page.locator("input[name=\"email\"]").fill(f"{random_string}@gmail.com")
    page.locator("input[name=\"email\"]").press("Tab")
    page.locator("input[name=\"password\"]").fill("1")
    page.locator("input[name=\"password\"]").press("Tab")
    page.locator("input[name=\"password2\"]").fill("1")
    page.get_by_role("button", name="Sign Up").click()
    
    # Assert that the user was created

    # Log in
    page.locator("input[name=\"username\"]").click()
    page.locator("input[name=\"username\"]").fill(random_string)
    page.locator("input[name=\"username\"]").press("Tab")
    page.locator("input[name=\"password\"]").fill("1")
    page.get_by_role("button", name="Sign In").click()
    
    # Assert that the user was signed in and can create messages
    expect(page.locator("body")).to_contain_text("You were logged in")

    # expect(page.get_by_role("emphasis")).to_contain_text("There's no message so far.")
    
    expect(page.get_by_role("button", name="Share")).to_be_visible()
    expect(page.get_by_role("button")).to_contain_text("Share")
    
    # Create and send message
    page.get_by_role("textbox").click()
    page.get_by_role("textbox").fill("test message")

    page.get_by_role("button", name="Share").click()
    expect(page.get_by_role("listitem").filter(has_text="test message")).to_be_visible()
