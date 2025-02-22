require 'sinatra'
require 'sinatra/flash'
require 'sinatra/content_for'
require 'pg'
require 'digest/md5'
require 'digest/sha2'
require 'json'
require 'dotenv/load'

# configuration
PER_PAGE = 30
DEBUG = true

configure do
    set :port, 4567
    set :bind, '0.0.0.0'
    enable :sessions
    set :session_secret, ENV.fetch('SECRET_KEY')
    set :show_exceptions, DEBUG
    set :views, 'templates'
    set :public_folder, 'public'
end

def connect_db
    db = PG.connect(
        host: ENV.fetch('DB_HOST'),
        port: ENV.fetch('DB_PORT'),
        dbname: ENV.fetch('DB_NAME'),
        user: ENV.fetch('DB_USER'),
        password: ENV.fetch('DB_PASSWORD')
    )
    db
end

#def init_db
#    db = connect_db
#    schema = File.read(File.join(File.dirname(__FILE__), 'schema.sql'))
#    db.execute_batch(schema)
#end

def query_db(query, args=[], one=false)
    result = @db.exec_params(query, args)
    if one
        return result.any? ? result[0] : {}
    else
        return result.any? ? result.map { |row| row } : []
    end
  end

def get_user_id(username)
    db = connect_db
    row = query_db('''SELECT user_id FROM "user" WHERE username = $1''', [username], true)
    row ? row['user_id'] : nil
end

def format_datetime(timestamp)
  timestamp = timestamp.to_i if timestamp.is_a?(String)
  return nil unless timestamp.is_a?(Numeric) && timestamp >= 0
  Time.at(timestamp).utc.strftime('%Y-%m-%d @ %H:%M')
end

def gravatar_url(email, size = 80)
    hash = Digest::MD5.hexdigest(email.strip.downcase)
    "http://www.gravatar.com/avatar/#{hash}?d=identicon&s=#{size}"
end

def generate_pw_hash(password)
    digest = Digest::SHA256.new
    "pbkdf2:sha256:50000$" + Digest::SHA256.hexdigest(password)
end

def update_latest(params)
    parsed_command_id = params['latest'] ? params['latest'].to_i : -1
    if parsed_command_id == -1
        return
    end

    file = File.new(ENV.fetch('SIM_TRACKER_FILE'), "w")
    file.puts(parsed_command_id)
    file.close
end

def not_req_from_simulator(request)
    authorization = request.env["HTTP_AUTHORIZATION"]
    if authorization != "Basic c2ltdWxhdG9yOnN1cGVyX3NhZmUh" # Hardcoded even though its bad practice! >:(
        status 403
        content_type :json
        {
            error_msg: "You are not authorized to use this resource!",
            status: 403
        }.to_json
    end
end

def public_msgs(per_page)
    query_db('''
        SELECT *
        FROM message JOIN "user"
        ON message.author_id = "user".user_id
        WHERE message.flagged = 0
        ORDER BY message.pub_date DESC LIMIT $1
    ''', [per_page])
end

def filtered_msgs(messages)
    filtered_msgs = []
    messages.each do |message|
        filtered_msg = {}
        filtered_msg["content"] = message["text"]
        filtered_msg["pub_date"] = message["pub_date"]
        filtered_msg["user"] = message["username"]
        filtered_msgs << filtered_msg
    end
    filtered_msgs
end


# before each request, make sure the database is connected
before do
    @db = connect_db
    @user = nil # current logged in user
    @profile_user = nil # user whose profile is being viewed
    @followed = false # whether the current user is following the profile user
    @error = nil
    @show_follow_unfollow = false
    # check if the user is logged in
    if session[:user]
        @user = query_db('SELECT * FROM "user" WHERE user_id = $1', [session[:user]], true)
    end
end


# close the database after each request
after do
    @db.close if @db
end

post '/illegal-route' do
    x = not_req_from_simulator(request)
    x ? x : 'ok'
end

# Root
get '/' do
    """Shows a users timeline or if no user is logged in it will
    redirect to the public timeline.  This timeline shows the user's
    messages as well as all the messages of followed users.
    """
    if not @user
        redirect '/public'
    end
    puts "Getting messages User: #{@user}"
    @messages = query_db('''
        SELECT *
        FROM message JOIN "user"
        ON message.author_id = "user".user_id
        WHERE message.flagged = 0 AND (
            "user".user_id = $1 OR
            "user".user_id IN (SELECT whom_id FROM follower
                                    WHERE who_id = $2))
        ORDER BY message.pub_date DESC LIMIT $3''', 
        [session[:user], session[:user], PER_PAGE])
    
    # render the timeline
    erb :timeline
end

get '/public' do
    """Displays the latest messages of all users."""
    puts "Getting public messages"
    @messages = public_msgs(PER_PAGE)
    erb :timeline
end


get '/msgs' do
    update_latest(params)
    not_from_sim_response = not_req_from_simulator(request)
    if (not_from_sim_response)
        return not_from_sim_response
    end

    # get the number of messages to return
    no_msgs = params["no"] ? params["no"] : 100

    messages = public_msgs(no_msgs)

    filtered_msgs(messages).to_json
end

post '/msgs/:username' do
    update_latest(params)
    not_from_sim_response = not_req_from_simulator(request)
    if (not_from_sim_response)
        return not_from_sim_response
    end

    user_id = get_user_id(params[:username])
    halt 404, "User not found" unless user_id

    body = JSON.parse request.body.read
    message = body['message']
    if message
        @db.exec_params('''
            INSERT INTO message (author_id, text, pub_date, flagged)
            VALUES ($1, $2, $3, 0)
        ''', [user_id, Rack::Utils.escape_html(message), Time.now.to_i])
    end
    status 204
end

get '/msgs/:username' do
    update_latest(params)
    not_from_sim_response = not_req_from_simulator(request)
    if (not_from_sim_response)
        return not_from_sim_response
    end

    user_id = get_user_id(params[:username])
    halt 404, "User not found" unless user_id

    # get the number of messages to return
    no_msgs = params["no"] ? params["no"] : 100

    messages = query_db('''
        SELECT *
        FROM message JOIN "user"
        ON message.author_id = "user".user_id
        WHERE message.flagged = 0 and "user".user_id = $1
        ORDER BY message.pub_date DESC LIMIT $2
    ''', [user_id, no_msgs])

    filtered_msgs(messages).to_json
end


get '/login' do
    """Logs the user in."""
    if @user
        redirect '/'
    end
    erb :login
end

post '/login' do
    if @user
        puts "User: #{@user} already logged in redirecting to /"
        # already logged in
        redirect '/'
    end

    puts "Username: #{params[:username]}"
    # get the user
    result = query_db('''
        SELECT * FROM "user" WHERE username = $1
    ''', [params[:username]], true)

    if result.length <= 0
        @error = 'Invalid username'

    elsif result['pw_hash'] == generate_pw_hash(params[:password])
        @user = result
        # set the session when the user is logged in
        session[:user] = @user['user_id']
        # display a message
        flash[:notice] = 'You were logged in'
        # redirect to the timeline
        puts "User: #{@user} logged in redirecting to /"
        redirect '/'
    else
        @error = 'Invalid password'
    end
    # error message
    erb :login
end

get '/register' do
    """Displays the register form."""
    if @user
        redirect '/'
    end
    erb :register
end

def get_register_payload(request, is_simulator)
    if is_simulator
        body = JSON.parse request.body.read
        return {
            username: body['username'],
            email: body['email'],
            password: body['pwd'],
            password2: body['pwd']
        }
    end

    return {
        username: params[:username],
        email: params[:email],
        password: params[:password],
        password2: params[:password2]
    }
end


post '/register' do
    is_simulator = request.content_type == "application/json"
    payload = get_register_payload(request, is_simulator)
    username, email, password, password2 = payload.values_at(:username, :email, :password, :password2)
    
    if is_simulator
        update_latest(params)
    elsif @user
        redirect '/'
    end

    if not username or username == ''
        @error = 'You have to enter a username'
    elsif not email or not email.include? '@'
        @error = 'You have to enter a valid email address'
    elsif not password or password == ''
        @error = 'You have to enter a password'
    elsif not is_simulator and password != password2
        @error = 'The two passwords do not match'
    elsif get_user_id(username) != nil
        @error = 'The username is already taken'
    else
        @db.exec_params('''
            INSERT INTO "user" (username, email, pw_hash) VALUES ($1, $2, $3)
        ''', [username, email, generate_pw_hash(password)])

        if is_simulator
            status 204
        else
            flash[:notice] = 'You were successfully registered and can login now'
            redirect '/login'
        end
    end

    if is_simulator
        return {status: 400, error_msg: @error}.to_json
    else
        erb :register
    end
end

get '/logout' do
    """Logs the user out."""
    puts "Logging out user: #{@user}"
    if session[:user] or @user
        session[:user] = nil
    end
    @user = nil
    flash[:notice] = 'You were logged out'
    redirect '/public'
end

def follow(user_id, follows_username)
    follows_user_id = get_user_id(follows_username)
    halt 404, "User not found" unless user_id and follows_user_id
    @db.exec_params('INSERT INTO follower (who_id, whom_id) VALUES ($1, $2)', [user_id, follows_user_id])
end

def unfollow(user_id, unfollows_username)
    unfollows_user_id = get_user_id(unfollows_username)
    halt 404, "User not found" unless user_id and unfollows_user_id
    @db.exec_params('DELETE FROM follower WHERE who_id=$1 AND whom_id=$2', [user_id, unfollows_user_id])
end

get '/:username/follow' do 
    # halt 401, "Unauthorized" unless current_user
    # who_to_do_the_following = @user['user_id']
    username = params[:username]
    follow(@user["user_id"], username)

    flash[:notice] = "You are now following &#34;#{username}&#34;"
    redirect "/#{username}"
end

get '/:username/unfollow' do 
    # halt 401, "Unauthorized" unless current_user
    # who_to_do_the_following = @user['user_id']
    username = params[:username]
    unfollow(@user["user_id"], username)

    flash[:notice] = "You are no longer following #{username}"
    redirect "/#{username}"
end

get '/fllws/:username' do
    update_latest(params)
    req_from_simulator = not_req_from_simulator(request)
    if (req_from_simulator)
        return req_from_simulator
    end
    user_id = get_user_id(params[:username])
    halt 404, "User not found" unless user_id

    limit = params["no"] ? params["no"] : 100
    followers = query_db('''
        SELECT "user".username
        FROM "user"
        INNER JOIN follower ON follower.whom_id = "user".user_id
        WHERE follower.who_id=$1
        LIMIT $2
        ''', [user_id, limit])
    follower_names = followers.map { |f| f["username"] }
    {"follows": follower_names}.to_json
end

post '/fllws/:username' do
    update_latest(params)
    req_from_simulator = not_req_from_simulator(request)
    if (req_from_simulator)
        return req_from_simulator
    end
    user_id = get_user_id(params[:username])
    halt 404, "User not found" unless user_id

    body = JSON.parse request.body.read
    follows_username = body['follow']
    unfollows_username = body['unfollow']
    
    if follows_username
        follow(user_id, follows_username)
        return status 204
    elsif unfollows_username
        unfollow(user_id, unfollows_username)
        return status 204
    end
end

post '/add_message' do
    """Registers a new message for the user."""
    if not @user
        halt 401, "Unauthorized"
    end
    if params[:message]
        @db.exec_params('''
            INSERT INTO message (author_id, text, pub_date, flagged)
            VALUES ($1, $2, $3, 0)
        ''', [@user["user_id"], Rack::Utils.escape_html(params[:message]), Time.now.to_i])
        flash[:notice] = 'Your message was recorded'
    end
    redirect '/'
end

get '/latest' do
    path = ENV.fetch('SIM_TRACKER_FILE')

    latest_processed_command_id = begin
        file_content = File.read(path).strip
        file_content.match?(/^\d+$/) ? file_content.to_i : -1
    rescue
        -1
    end
    
    {latest: latest_processed_command_id}.to_json
end

# Place this in buttom, because the routes are evaluated from top to bottom
# e.g. /:username would match /login or /logout
get '/:username' do
    
    username = params[:username]
    puts "Getting profile for user: #{username}"
    # # Fetch the user's profile from the database
    @profile_user = query_db('SELECT * FROM "user" WHERE username = $1', [username]).first
    halt 404, "User not found" unless @profile_user
    puts "Getting profile_user: #{@profile_user}"

    @followed = false
    if @user
      @followed = query_db('SELECT 1 FROM follower WHERE follower.who_id = $1 AND follower.whom_id = $2',
                          [@user["user_id"], @profile_user['user_id']]).any?
        puts "#{@user["username"]} Follows #{@profile_user['username']}: #{@followed}"
    end
  
    # # Fetch the user's messages from the database
    @messages = query_db('''
      SELECT *
      FROM message JOIN "user"
      ON message.author_id = "user".user_id 
      WHERE "user".user_id = $1
      ORDER BY message.pub_date DESC LIMIT $2
    ''', [@profile_user['user_id'], PER_PAGE])
  
    # Render the timeline template (timeline.erb)
    @show_follow_unfollow = true
    erb :timeline
end
