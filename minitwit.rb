require 'sinatra'
require 'sinatra/flash'
require 'sinatra/content_for'
require 'sqlite3'
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
    path = ENV.fetch('DATABASE_PATH')
    db = SQLite3::Database.new(path)
    db.results_as_hash = true
    db
end

def init_db
    db = connect_db
    schema = File.read(File.join(File.dirname(__FILE__), 'schema.sql'))
    db.execute_batch(schema)
end

def query_db(query, args=[], one=false)
    # define results before execute to be in the right scope
    results = []
    @db.execute(query, args) do |row|
        return row if one
        results << row
    end
    results
end

def get_user_id(username)
    db = connect_db
    row = db.get_first_row("select user_id from user where username = ?", username)
    row ? row['user_id'] : nil
end

def format_datetime(timestamp)
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
        @user = query_db('select * from user where user_id = ?', [session[:user]], true)
    end
end


# close the database after each request
after do
    @db.close if @db
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
        select message.*, user.* from message, user
        where message.flagged = 0 and message.author_id = user.user_id and (
            user.user_id = ? or
            user.user_id in (select whom_id from follower
                                    where who_id = ?))
        order by message.pub_date desc limit ?''', 
        [session[:user], session[:user], PER_PAGE])
    
    # render the timeline
    erb :timeline
end

get '/public' do
    update_latest(params)
    """Displays the latest messages of all users."""
    puts "Getting public messages"
    @messages = query_db('''
        select message.*, user.* from message, user
        where message.flagged = 0 and message.author_id = user.user_id
        order by message.pub_date desc limit ?''', [PER_PAGE])
    erb :timeline
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
        select * from user where username = ?
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

post '/register' do
    if @user
        redirect '/'
    end
    if not params[:username] or params[:username] == ''
        @error = 'You have to enter a username'
    elsif not params[:email] or not params[:email].include? '@'
        @error = 'You have to enter a valid email address'
    elsif not params[:password] or params[:password] == ''
        @error = 'You have to enter a password'
    elsif params[:password] != params[:password2]
        @error = 'The two passwords do not match'
    elsif get_user_id(params[:username]) != nil
        @error = 'The username is already taken'
    else
        @db.execute('''
            insert into user (username, email, pw_hash) values (?, ?, ?)
        ''', [params[:username], params[:email], generate_pw_hash(params[:password])])
        flash[:notice] = 'You were successfully registered and can login now'
        redirect '/login'
    end
    erb :register
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

get '/:username/follow' do 
    username = params[:username]
    # halt 401, "Unauthorized" unless current_user
    # who_to_do_the_following = @user['user_id']
    @profile_user = query_db('SELECT * FROM user WHERE username = ?', [username]).first
    halt 404, "User not found" unless @profile_user
  
    @db.execute('INSERT INTO follower (who_id, whom_id) VALUES (?, ?)', [@user["user_id"], @profile_user['user_id']])


    flash[:notice] = "You are now following &#34;#{username}&#34;"
    redirect "/#{username}"
end

get '/:username/unfollow' do 
    username = params[:username]
    # halt 401, "Unauthorized" unless current_user
    # who_to_do_the_following = @user['user_id']
    @profile_user = query_db('SELECT * FROM user WHERE username = ?', [username]).first
    halt 404, "User not found" unless @profile_user
    
    @db.execute('delete from follower where who_id=? and whom_id=?', [@user["user_id"], @profile_user['user_id']])

    flash[:notice] = "You are no longer following #{username}"
    redirect "/#{username}"
end

post '/add_message' do
    """Registers a new message for the user."""
    if not @user
        halt 401, "Unauthorized"
    end
    if params[:message]
        @db.execute('''
            insert into message (author_id, text, pub_date, flagged)
            values (?, ?, ?, 0)
        ''', [@user["user_id"], Rack::Utils.escape_html(params[:message]), Time.now.to_i])
        flash[:notice] = 'Your message was recorded'
    end
    redirect '/'
end


# Place this in buttom, because the routes are evaluated from top to bottom
# e.g. /:username would match /login or /logout
get '/:username' do
    
    username = params[:username]
    puts "Getting profile for user: #{username}"
    # # Fetch the user's profile from the database
    @profile_user = query_db('SELECT * FROM user WHERE username = ?', [username]).first
    halt 404, "User not found" unless @profile_user
    puts "Getting profile_user: #{@profile_user}"

    # TODO: I dont know how to use this followed yet
    @followed = false
    if @user
      @followed = query_db('SELECT 1 FROM follower WHERE follower.who_id = ? AND follower.whom_id = ?',
                          [@user["user_id"], @profile_user['user_id']]).any?
        puts "#{@user["username"]} Follows #{@profile_user['username']}: #{@followed}"
    end
  
    # # Fetch the user's messages from the database
    @messages = query_db('''
      SELECT message.*, user.* FROM message, user 
      WHERE user.user_id = message.author_id AND user.user_id = ?
      ORDER BY message.pub_date DESC LIMIT ?
    ''', [@profile_user['user_id'], PER_PAGE])
  
    # Render the timeline template (timeline.erb)
    @show_follow_unfollow = true
    erb :timeline
end
