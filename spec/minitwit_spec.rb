require "spec_helper"

def register(username, password, password2 = nil, email = nil)
  password2 ||= password
  email ||= "#{username}@example.com"
  post "/register", {username: username, password: password, password2: password2, email: email}

  if last_response.redirect?
    follow_redirect!
  end
end

def login(username, password)
  post "/login", {username: username, password: password}

  if last_response.redirect?
    follow_redirect!
  end
end

def add_message(text)
  post "/add_message", {message: text}

  if last_response.redirect?
    follow_redirect!
    expect(last_response.body).to include("Your message was recorded")
  end
end

def register_and_login(username, password)
  register(username, password)
  login(username, password)
end

def logout
  get "/logout"
  follow_redirect!
end

describe "Full application test" do
  it "Simple test" do
    register("user1", "default")
    expect(last_response.body).to include("You were successfully registered and can login now")
  end

  it "Register" do
    register("user1", "default")
    expect(last_response.body).to include("You were successfully registered and can login now")

    register("user1", "default")
    expect(last_response.body).to include("The username is already taken")

    register("", "default")
    expect(last_response.body).to include("You have to enter a username")

    register("user2", "")
    expect(last_response.body).to include("You have to enter a password")

    register("user2", "default", "default2")
    expect(last_response.body).to include("The two passwords do not match")

    register("user2", "ye", "ye", "broken")
    expect(last_response.body).to include("You have to enter a valid email address")
  end

  it "Login & logout" do
    register_and_login("user1", "default")
    expect(last_response.body).to include("You were logged in")

    login("user1", "default")
    expect(last_response.body).not_to include("You were logged in")

    logout
    expect(last_response.body).to include("You were logged out")

    login("user1", "wrongpassword")
    expect(last_response.body).to include("Invalid password")

    login("user2", "default")
    expect(last_response.body).to include("Invalid username")
  end

  it "Add message" do
    register_and_login("user1", "default")
    add_message("Hello, world! 1")
    add_message("<Hello, world!>")
    get "/"
    expect(last_response.body).to include("Hello, world! 1")
    expect(last_response.body).to include("&lt;Hello, world!&gt;")
  end

  it "Timelines" do
    register_and_login("foo", "default")
    add_message("the message by foo")
    logout

    register_and_login("bar", "default")
    add_message("the message by bar")

    get "/public"
    expect(last_response.body).to include("the message by foo")
    expect(last_response.body).to include("the message by bar")

    # bar"s timeline should just show bar"s message
    get "/"
    expect(last_response.body).to include("the message by bar")
    expect(last_response.body).not_to include("the message by foo")

    # now let"s follow foo
    get "/foo/follow"
    follow_redirect!
    expect(last_response.body).to include("You are now following &#34;foo&#34;")

    # we should now see foo"s message
    get "/"
    expect(last_response.body).to include("the message by foo")
    expect(last_response.body).to include("the message by bar")

    # but on the user"s page we only want the user"s message
    get "/bar"
    expect(last_response.body).not_to include("the message by foo")
    expect(last_response.body).to include("the message by bar")

    # and on foo"s page we only want foo"s message
    get "/foo"
    expect(last_response.body).to include("the message by foo")
    expect(last_response.body).not_to include("the message by bar")
  end

  # create a test that checks my timeline works when I follow multiple people
  it "My timeline works when I follow multiple people" do
    # register and login as user1
    register_and_login("user1", "default")

    # add a message
    add_message("Hello, world! 1")

    # logout
    logout

    # register and login as user2
    register_and_login("user2", "default")

    # add a message
    add_message("Hello, world! 2")

    # logout
    logout

    # register and login as user3
    register_and_login("user3", "default")

    # add a message
    add_message("Hello, world! 3")

    # logout
    logout

    # register and login as user4
    register_and_login("user4", "default")

    # add a message
    add_message("Hello, world! 4")

    # logout
    logout

    # sign in as user 1
    login("user1", "default")

    # follow user2
    get "/user2/follow"
    follow_redirect!
    expect(last_response.body).to include("You are now following &#34;user2&#34;")

    # follow user3
    get "/user3/follow"
    follow_redirect!
    expect(last_response.body).to include("You are now following &#34;user3&#34;")

    # follow user4
    get "/user4/follow"
    follow_redirect!
    expect(last_response.body).to include("You are now following &#34;user4&#34;")

    # check the timeline
    get "/"

    # check status code
    expect(last_response.status).to eq(200)

    # expect to see all the messages
    expect(last_response.body).to include("Hello, world! 1")
    expect(last_response.body).to include("Hello, world! 2")
    expect(last_response.body).to include("Hello, world! 3")
    expect(last_response.body).to include("Hello, world! 4")
  end
end
