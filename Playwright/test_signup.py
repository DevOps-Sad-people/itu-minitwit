from playwright.sync_api import Page, expect


def test_sign_up_empty_db(page: Page) -> None:
    page.goto("http://localhost:4567/public")
    expect(page.get_by_role("emphasis")).to_contain_text("There's no message so far.")
    expect(page.get_by_role("heading")).to_contain_text("MiniTwit")
    expect(page.locator("body")).to_contain_text("MiniTwit — A Ruby Sinatra Application")
    expect(page.locator("body")).to_contain_text("sign in")
    expect(page.locator("body")).to_contain_text("sign up")
    expect(page.get_by_text("MiniTwit — A Ruby Sinatra")).to_be_visible()
    expect(page.locator("body")).to_contain_text("Page 1 of 1")
    page.get_by_role("link", name="sign up").click()
    page.locator("input[name=\"username\"]").click()
    page.locator("input[name=\"username\"]").fill("b")
    page.locator("input[name=\"username\"]").press("Tab")
    page.locator("input[name=\"email\"]").fill("a@a.dk")
    page.locator("input[name=\"email\"]").press("Tab")
    page.locator("input[name=\"password\"]").fill("1234")
    page.locator("input[name=\"password\"]").press("Tab")
    page.locator("input[name=\"password2\"]").fill("1234")
    expect(page.get_by_role("button", name="Sign Up")).to_be_visible()
    expect(page.get_by_role("button")).to_contain_text("Sign Up")
    page.get_by_role("button", name="Sign Up").click()
    expect(page.get_by_role("listitem")).to_contain_text("You were successfully registered and can login now")
    