# itu-minitwit
## Start developing:

- Install Ruby version 3.3
- run `bundle install`

## Using Docker

- Install `docker build -t my-ruby-app .`
- Run `docker run -it -p 4567:4567 my-ruby-app`

### To develop

`docker run -it --rm \
    --name my-ruby-server \
    -v $(pwd)/:/app \
    -p 4567:4567 \
    -w /app \
    ruby:3.3 bash -c "bundle install; ruby minitwit.rb"`

### developing erb files

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
