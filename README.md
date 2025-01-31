# itu-minitwit

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
 