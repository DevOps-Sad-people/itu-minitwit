require 'sinatra'
require 'sqlite3'
require 'digest/md5'
require 'digest/sha2'
require 'json'

# configuration
DATABASE = './tmp/minitwit.db'
PER_PAGE = 30
DEBUG = true
SECRET_KEY = 'development key development key development key development key development key development key development key'

configure do
    set :port, 4567
    set :bind, '0.0.0.0'
    enable :sessions
    set :session_secret, SECRET_KEY
    set :show_exceptions, DEBUG
    set :views, File.join(File.dirname(__FILE__), 'templates')
    set :public_folder, __dir__ + '/public'
end

def connect_db
    db = SQLite3::Database.new(DATABASE)
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

# before each request, make sure the database is connected
before do
    @db = connect_db
    @user = nil
    @error = nil
    @flashes = nil
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
        redirect '/public_timeline'
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

get '/public_timeline' do
    """Displays the latest messages of all users."""
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

    # check the password
    if result.length > 0 && result['pw_hash'] == generate_pw_hash(params[:password])

        @user = result
        # set the session when the user is logged in
        session[:user] = @user['user_id']
        # display a message
        @flashes = 'You were logged in'
        # redirect to the timeline
        puts "User: #{@user} logged in redirecting to /"
        redirect '/'
    end

    @error = 'The username or password is incorrect.'
    # error message
    erb :login
end

# get '/:username' do
#     username = params[:username]
  
#     # Fetch the user's profile from the database
#     profile_user = query_db('SELECT * FROM user WHERE username = ?', [username]).first
#     halt 404, "User not found" unless profile_user
  
#     followed = false
#     if session[:user_id]
#       followed = query_db('SELECT 1 FROM follower WHERE follower.who_id = ? AND follower.whom_id = ?',
#                           [session[:user_id], profile_user['user_id']]).any?
#     end
  
#     # Fetch the user's messages from the database
#     messages = query_db('''
#       SELECT message.*, user.* FROM message, user 
#       WHERE user.user_id = message.author_id AND user.user_id = ?
#       ORDER BY message.pub_date DESC LIMIT ?
#     ''', [profile_user['user_id'], PER_PAGE])
  
#     # Render the timeline template (timeline.erb)
#     erb :timeline, locals: { messages: messages, followed: followed, profile_user: profile_user }
#   end

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
    if not params[:username]
        @error = 'You have to enter a username'
    elsif not params[:email] or not params[:email].include? '@'
        @error = 'You have to enter a valid email address'
    elsif not params[:password]
        @error = 'You have to enter a password'
    elsif params[:password] != params[:password2]
        @error = 'The two passwords do not match'
    elsif get_user_id(params[:username]) != nil
        @error = 'The username is already taken'
    else
        @db.execute('''
            insert into user (username, email, pw_hash) values (?, ?, ?)
        ''', [params[:username], params[:email], generate_pw_hash(params[:password])])
        @flashes = 'You were successfully registered and can login now'
        redirect '/login'
    end
    erb :register
end

get '/logout' do
    """Logs the user out."""
    if session[:user]
        session[:user] = nil
    end
    @user = nil
    @flashes = 'You were logged out'
    redirect '/'
end