# itu-minitwit
## Setup:

- Install Ruby version 3.3
- Setup .env file (Copy .env.example)
- Setup postgres (Add postgres credentials to the .env file)
- `bundle install` to install packages
- `sh control.sh init` to init db.
- `ruby minitwit.rb` to run program.

## Using Docker

`docker compose up -d`

### Interactive development
**A single start**
Create network:
`docker network create minitwit`

Run ruby:
`docker run -it --rm \
    --name my-ruby-server \
    --network=minitwit \
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
Create network:
`docker network create minitwit`

1. `docker run -it --rm \
    --name my-ruby-server \
    --network=minitwit \
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
| `/illegal-route'`    | `POST`  | Request validation check, if from simulator or not                |


## Database

### Setup
Create and run a Postgresql docker container:
`docker run --name minitwit-postgres --network=minitwit -e POSTGRES_PASSWORD=postgres -d -p 5432:5432 postgres`

Restoring from a dump file:
```
docker exec -it minitwit-postgres /bin/bash
psql -U postgres -d minitwit -f minitwit_db.sql

```

Creating a dump file:
`docker exec minitwit-postgres pg_dump -U postgres -F t postgres > db_dump.sql`



### Methods
| Method               |Parameters                 | Returns       | Description                |
|----------------------|---------------------------|---------------|----------------------------|
| `connect_db`         | None                      |`db`           | Connect to db |
| `init_db`            | None                      | void          | init database|
| `query_db`           | query, args=[], one=false |`results`      | query the database|
| `get_user_id`        | username: string          |`user_id`/`nil`| get user_id from username|

### Helper methods
| Method               |Parameters      | Returns      | Description                |
|----------------------|----------------|------------- |----------------------------|
| `generate_pw_hash`   | password       |`hashed_password`| Generate hashed password|
| `update_latest`      | params         | void          | update latest command ID |
| `format_datetime`    | timestamp      | `formatted_time` | Formats datetime to 'Y-m-d @ H:M'|
| `gravatar_url`       | email, size=80 | `url_to_image` | generate the url to image |


## Deployment
It is assumed that your SSH keys are located in your home directory in the hidden directory `~/.ssh/id_ed25519`. In case you have them stored somewhere else, you have to modify the line `config.ssh.private_key_path = '~/.ssh/id_ed25519'` in the Vagrantfile accordingly.

### Excluding files from deployment
If you want to exclude a file/folder from the deployment process, you need to modify the config.vm.synced_folder line in the Vagrantfile and add it to the rsync__exclude option.


### Other observations 
- Hashing sha256
- Opens and closes db connection for each request
- Flagging system. 
- time: Unix seconds
- Requests return HTML


## Compile flag tool
```bash
gcc flag_tool.c -o flag_tool -lsqlite3
```
