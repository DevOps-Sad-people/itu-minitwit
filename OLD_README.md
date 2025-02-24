# itu-minitwit
## Setup:

- Install Ruby version 3.3
- Setup .env file (Copy .env.example)
- `bundle install` to install packages
- `sh control.sh init` to init db.
- `ruby minitwit.rb` to run program.

## Using Docker

- Install `docker build -t my-ruby-app .`
- Run `docker run -it -p 4567:4567 my-ruby-app`

### Interactive development
**A single start**
`docker run -it --rm \
    --name my-ruby-server \
    -v $(pwd)/:/app \
    -p 4567:4567 \
    -w /app \
    ruby:3.3 bash -c "bundle install; ruby minitwit.rb"`

**A single test-run**
`docker run -it --rm \
    --name my-ruby-server \
    -v $(pwd)/:/app \
    -w /app \
    ruby:3.3 bash -c "bundle install; rspec"`

**Interactive and reusable environment (Recommended)**
1. `docker run -it --rm \
    --name my-ruby-server \
    -v $(pwd)/:/app \
    -p 4567:4567 \
    -w /app \
    ruby:3.3 bash`
2. `bundle install`
3. Run `rspec` to test. `ruby minitwit.rb` to start app.

## Testing
All tests are performed using RSpec, which is a great DSL for expressing tests. To add tests, use `spec/minitwit_spec.rb` as inspiration. Add `XXXX_spec.rb` to the `spec/` folder, import `spec_helper`, and write as many tests as you should require.

## developing erb files

The `.erb` files are in folder `templates/`

read more about the erb syntax [here](https://www.puppet.com/docs/puppet/5.5/lang_template_erb.html)

The css file is in the `public/stylesheets` folder.

The erb structure and syntax
```erb
<%# Non-printing tag ↓ -%>
<% if @keys_enable -%>
<%# Expression-printing tag ↓ -%>
keys <%= @keys_file %>
<% unless @keys_trusted.empty? -%>
trustedkey <%= @keys_trusted.join(' ') %>
<% end -%>
<% if @keys_requestkey != '' -%>
requestkey <%= @keys_requestkey %>
<% end -%>
<% if @keys_controlkey != '' -%>
controlkey <%= @keys_controlkey %>
<% end -%>

<% end -%>
``` 

## Endpoints
`:username` in a route means it is a dynamic route parameter - this means `:username` is placeholder for a real username.
E.g the username `nicra` - the route `/nicra` would show the profile of `nicra`

**Note**:   
You should place route with dynamic route parameters in the buttom of files, because the routes are evaluated from top to bottom.
e.g. /:username would match /login or /logout

### Minitwit endpoints (returns html)
| Endpoint             | Method       | Description                |
|----------------------|------------- |----------------------------|
| `/`                  | `GET`        | Root/Home page. Shows timeline.             |
| `/login`             | `GET, POST`  | User login                 |
| `/register`          | `GET, POST`  | User registration          |
| `/logout`            | `GET`        | User logout                |
| `/public`            | `GET`        | Displays the latest messages of all users.       |
| `/:username/follow`  | `GET`        | Follow a user              |
| `/:username/unfollow`| `GET`        | Unfollow a user            |
| `/add_message`       | `POST`       | Add a new message          |
| `/:username`         | `GET`        | View user profile/messages |


### Api Endpoints (GET returns JSON and POST status code)

| Endpoint             | Method       | Description                |
|----------------------|------------- |----------------------------|
| `/msgs`              | `GET`        | Get public messages        |
| `/msgs/:username`    | `GET, POST`  | GET: Public messages for a specific user. POST: post a new message for a specific username.                 |
| `/fllws/:username`   | `GET, POST`  | GET: Returns a list of users whom the given user follows. POST: Allows a user to follow or unfollow another user                 |
| `/latest`            | `GET`  | Retrieves the latest processed command ID                 |



## Observations


### DB

- `init_db()`
- `connect_db()`
- `query_db()`

### Other observations 
- Hashing md5
- Opens and closes db connection for each request
- Flagging system. 
- time: Unix seconds
- Requests return HTML



### POST/GET Features
- (un)follow
    - route(/<username>/follow)
    - route(/<username>/unfollow)
- `timeline` 
    - (shows tweets)
    - route('/')
    - tweets from those you follow  
- `public_timeline()`
    - route('/public')
    - Show every tweet
- `user_timeline(username)`
    - route('/<username>')
    - displays a users tweet
- `add_message()`
    - route(/add_message) POST
- `login`
- `logout`
- `register`
### Other problems


## Set up env
Create env
```bash
python3 -m venv venv
```
Activate env
```bash
source venv/bin/activate
```
Deactivate env
```bash
deactivate
```

## Install requirements
This is used to install all the required packages from the requirements file
```bash
pip install -r requirements.txt
```

## Update requirements file
This is used to update the requirements file with the current packages.
```bash
pip freeze > requirements.txt
```

## Compile flag tool
```bash
gcc flag_tool.c -o flag_tool -lsqlite3
```
