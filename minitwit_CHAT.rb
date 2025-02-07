require 'sinatra'
require 'sinatra/flash'
require 'sqlite3'
require 'bcrypt'
require 'digest/md5'
require 'time'

# configuration
DATABASE = './tmp/minitwit.db'
PER_PAGE = 30
DEBUG = true
SECRET_KEY = 'development key'

configure do
  enable :sessions
  set :session_secret, SECRET_KEY
  set :show_exceptions, DEBUG
  set :views, File.join(File.dirname(__FILE__), 'views')
end

helpers do
  # Executes a query with optional arguments. If `one` is true, returns a single result.
  def query_db(query, args = [], one = false)
    results = @db.execute(query, *args)
    one ? results.first : results
  end

  # Looks up the user_id given a username.
  def get_user_id(username)
    row = @db.get_first_row("select user_id from user where username = ?", username)
    row ? row['user_id'] : nil
  end

  # Formats a Unix timestamp to a readable UTC string.
  def format_datetime(timestamp)
    Time.at(timestamp).utc.strftime('%Y-%m-%d @ %H:%M')
  end

  # Returns the Gravatar URL for the given email.
  def gravatar_url(email, size = 80)
    hash = Digest::MD5.hexdigest(email.strip.downcase)
    "http://www.gravatar.com/avatar/#{hash}?d=identicon&s=#{size}"
  end

  # Expose formatting functions to templates.
  def datetimeformat(timestamp)
    format_datetime(timestamp)
  end

  def gravatar(email, size = 80)
    gravatar_url(email, size)
  end
end

# Initialize the database by reading and executing the schema file.
def init_db
  db = SQLite3::Database.new(DATABASE)
  db.results_as_hash = true
  schema_path = File.join(File.dirname(__FILE__), 'schema.sql')
  schema = File.read(schema_path)
  db.execute_batch(schema)
  db.close
end

# Before every request, open a connection to the database and set the current user.
before do
  @db = SQLite3::Database.new(DATABASE)
  @db.results_as_hash = true
  if session[:user_id]
    @user = query_db("select * from user where user_id = ?", [session[:user_id]], true)
  else
    @user = nil
  end
end

# After each request, close the database connection.
after do
  @db.close if @db
end

# Home timeline: If a user is logged in, show their timeline; otherwise, redirect to public.
get '/' do
  puts "We got a visitor from: #{request.ip}"
  unless @user
    redirect to('/public')
  end
  offset = params['offset'] ? params['offset'].to_i : 0
  messages = query_db(<<-SQL, [session[:user_id], session[:user_id], PER_PAGE])
    select message.*, user.*
    from message, user
    where message.flagged = 0 and message.author_id = user.user_id and (
      user.user_id = ? or
      user.user_id in (select whom_id from follower where who_id = ?)
    )
    order by message.pub_date desc limit ?
  SQL
  erb :timeline, locals: { messages: messages }
end

# Public timeline: Displays the latest messages from all users.
get '/public' do
  messages = query_db(<<-SQL, [PER_PAGE])
    select message.*, user.*
    from message, user
    where message.flagged = 0 and message.author_id = user.user_id
    order by message.pub_date desc limit ?
  SQL
  erb :timeline, locals: { messages: messages }
end

# Login routes: GET shows the login form, POST handles authentication.
get '/login' do
  redirect to('/') if @user
  erb :login, locals: { error: nil }
end

post '/login' do
  redirect to('/') if @user
  user = query_db("select * from user where username = ?", [params[:username]], true)
  if user.nil?
    error = "Invalid username"
  elsif !BCrypt::Password.new(user['pw_hash']).is_password?(params[:password])
    error = "Invalid password"
  else
    flash[:notice] = "You were logged in"
    session[:user_id] = user['user_id']
    redirect to('/')
  end
  erb :login, locals: { error: error }
end

# Registration routes: GET shows the registration form, POST handles user creation.
get '/register' do
  redirect to('/') if @user
  erb :register, locals: { error: nil }
end

post '/register' do
  redirect to('/') if @user
  if params[:username].to_s.strip.empty?
    error = "You have to enter a username"
  elsif params[:email].to_s.strip.empty? || !params[:email].include?("@")
    error = "You have to enter a valid email address"
  elsif params[:password].to_s.empty?
    error = "You have to enter a password"
  elsif params[:password] != params[:password2]
    error = "The two passwords do not match"
  elsif get_user_id(params[:username])
    error = "The username is already taken"
  else
    pw_hash = BCrypt::Password.create(params[:password])
    @db.execute("insert into user (username, email, pw_hash) values (?, ?, ?)",
                params[:username], params[:email], pw_hash)
    flash[:notice] = "You were successfully registered and can login now"
    redirect to('/login')
  end
  erb :register, locals: { error: error }
end

# Logout route: Logs the user out and redirects to the public timeline.
get '/logout' do
  flash[:notice] = "You were logged out"
  session.delete(:user_id)
  redirect to('/public')
end

# Add a new message.
post '/add_message' do
  halt 401 unless session[:user_id]
  if params[:text] && !params[:text].empty?
    @db.execute("insert into message (author_id, text, pub_date, flagged) values (?, ?, ?, 0)",
                session[:user_id], params[:text], Time.now.to_i)
    flash[:notice] = "Your message was recorded"
  end
  redirect to('/')
end

# Follow a user.
get '/:username/follow' do
  halt 401 unless @user
  username = params[:username]
  whom_id = get_user_id(username)
  halt 404 if whom_id.nil?
  @db.execute("insert into follower (who_id, whom_id) values (?, ?)", session[:user_id], whom_id)
  flash[:notice] = "You are now following \"#{username}\""
  redirect to("/#{username}")
end

# Unfollow a user.
get '/:username/unfollow' do
  halt 401 unless @user
  username = params[:username]
  whom_id = get_user_id(username)
  halt 404 if whom_id.nil?
  @db.execute("delete from follower where who_id = ? and whom_id = ?", session[:user_id], whom_id)
  flash[:notice] = "You are no longer following \"#{username}\""
  redirect to("/#{username}")
end

# User timeline: Shows the messages for a particular user.
get '/:username' do
  username = params[:username]
  profile_user = query_db("select * from user where username = ?", [username], true)
  halt 404 if profile_user.nil?
  followed = false
  if @user
    followed = !query_db("select 1 from follower where who_id = ? and whom_id = ?",
                          [session[:user_id], profile_user['user_id']], true).nil?
  end
  messages = query_db(<<-SQL, [profile_user['user_id'], PER_PAGE])
    select message.*, user.*
    from message, user
    where user.user_id = message.author_id and user.user_id = ?
    order by message.pub_date desc limit ?
  SQL
  erb :timeline, locals: { messages: messages, followed: followed, profile_user: profile_user }
end

run! if __FILE__ == $0