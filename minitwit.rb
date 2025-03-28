require "sinatra"
require "sinatra/flash"
require "sinatra/content_for"
require "pg"
require "digest/md5"
require "digest/sha2"
require "json"
require "dotenv/load"
require "sequel"
require "rack"
require "prometheus/middleware/exporter"
require "active_support/time"
require_relative "db_migrations"
require_relative "prometheus_config"

# configuration
PER_PAGE = 30
DEBUG = true
DB_URL = "postgres://#{ENV.fetch("DB_USER")}:#{ENV.fetch("DB_PASSWORD")}@#{ENV.fetch("DB_HOST")}:#{ENV.fetch("DB_PORT")}/#{ENV.fetch("DB_NAME")}"

use Rack::Deflater
use Prometheus::Middleware::Exporter
use PrometheusCollector

configure do
  set :port, 4567
  set :bind, "0.0.0.0"
  enable :sessions
  set :session_secret, ENV.fetch("SECRET_KEY")
  set :show_exceptions, DEBUG
  set :views, "templates"
  set :public_folder, "public"
  set :environment, :production
end

DB = Sequel.connect(DB_URL)
migrate_db(DB)

class User < Sequel::Model(:user); end

class Follower < Sequel::Model(:follower); end

class Message < Sequel::Model(:message); end

class Request < Sequel::Model(:request); end

def get_user_id(username)
  User.where(username: username).get(:user_id)
end

def format_datetime(timestamp)
  timestamp = timestamp.to_i if timestamp.is_a?(String)
  return nil unless timestamp.is_a?(Numeric) && timestamp >= 0
  Time.at(timestamp).in_time_zone("Copenhagen").strftime("%d-%m-%Y @ %H:%M")
end

def gravatar_url(email, size = 80)
  hash = Digest::MD5.hexdigest(email.strip.downcase)
  "http://www.gravatar.com/avatar/#{hash}?d=identicon&s=#{size}"
end

def generate_pw_hash(password)
  "pbkdf2:sha256:50000$" + Digest::SHA256.hexdigest(password)
end

def update_latest(params, request)
  parsed_command_id = params["latest"] ? params["latest"].to_i : -1
  if parsed_command_id == -1
    return
  end

  # Write the latest id to db
  puts "Updating latest id to: #{parsed_command_id}"

  # If the is no request in db then insert it
  if Request.count == 0
    Request.insert(latest_id: parsed_command_id, request: request)
  else
    Request.first.update(latest_id: parsed_command_id, request: request)
  end
end

def not_req_from_simulator(request)
  authorization = request.env["HTTP_AUTHORIZATION"]
  # Hardcoded even though its bad practice! >:(
  if authorization != "Basic c2ltdWxhdG9yOnN1cGVyX3NhZmUh"
    halt 403,
      {
        error_msg: "You are not authorized to use this resource!",
        status: 403
      }.to_json
  end
end

def public_msgs(per_page, page = 1)
  offset = (page - 1) * per_page.to_i
  puts offset
  Message.dataset.join(User.dataset, user_id: :author_id).where(flagged: 0).order(Sequel.desc(:pub_date)).offset(offset).limit(per_page).all
end

def filtered_msgs(messages)
  filtered_msgs = []
  messages.each do |message|
    filtered_msg = {}
    filtered_msg["content"] = message.values[:text]
    filtered_msg["pub_date"] = message.values[:pub_date]
    filtered_msg["user"] = message.values[:username]
    filtered_msgs << filtered_msg
  end
  filtered_msgs
end

def user_not_found
  halt 404, "User not found"
end

# before each request, make sure the database is connected
before do
  @user = nil # current logged in user
  @profile_user = nil # user whose profile is being viewed
  @followed = false # whether the current user is following the profile user
  @error = nil
  @page = 1
  @show_follow_unfollow = false
  # check if the user is logged in
  if session[:user]
    @user = User.where(user_id: session[:user]).first
  end
end

# Root
# Shows a users timeline or if no user is logged in it will
# redirect to the public timeline.  This timeline shows the user's
# messages as well as all the messages of followed users.
get "/" do
  if !@user
    redirect "/public"
  end

  page = params[:page].to_i
  page = 1 if page < 1

  offset = (page - 1) * PER_PAGE

  @page = page

  all_messages = Message
    .join(User.dataset.as(:user), Sequel[:user][:user_id] => :author_id)
    .where(flagged: 0)
    .where(Sequel[:user][:user_id] => session[:user])
    .or(Sequel[:user][:user_id] => Follower.where(who_id: session[:user]).select(:whom_id))
    .order(Sequel.desc(:pub_date))

  max_page = (all_messages.count / PER_PAGE.to_f).ceil
  max_page = 1 if max_page < 1
  @max_page = max_page

  puts "Getting messages User: #{@user}"
  @messages =
    all_messages
      .offset(offset)
      .limit(PER_PAGE)
      .all

  @has_more = @messages.size == PER_PAGE
  # render the timeline
  erb :timeline
end

# Displays the latest messages of all users.
get "/public" do
  puts "Getting public messages"
  page = params[:page].to_i
  page = 1 if page < 1

  @page = page
  max_page = (Message.where(flagged: 0).count / PER_PAGE.to_f).ceil
  max_page = 1 if max_page < 1
  @max_page = max_page

  @messages = public_msgs(PER_PAGE, page)
  @has_more = @messages.size == PER_PAGE
  erb :timeline
end

get "/msgs" do
  update_latest(params, "GET /msgs")
  not_from_sim_response = not_req_from_simulator(request)
  if not_from_sim_response
    return not_from_sim_response
  end

  # get the number of messages to return
  no_msgs = params["no"] || 100

  messages = public_msgs(no_msgs)

  filtered_msgs(messages).to_json
end

post "/msgs/:username" do
  update_latest(params, "POST /msgs")
  not_from_sim_response = not_req_from_simulator(request)
  if not_from_sim_response
    return not_from_sim_response
  end

  user_id = get_user_id(params[:username])
  user_not_found unless user_id

  body = JSON.parse request.body.read
  message = body["content"]
  if message
    Message.insert(author_id: user_id, text: Rack::Utils.escape_html(message), pub_date: Time.now.to_i, flagged: 0)
  end
  status 204
end

get "/msgs/:username" do
  update_latest(params, "GET /msgs")
  not_from_sim_response = not_req_from_simulator(request)
  if not_from_sim_response
    return not_from_sim_response
  end

  user_id = get_user_id(params[:username])

  user_not_found unless user_id

  # get the number of messages to return
  no_msgs = params["no"] || 100

  messages = Message.dataset.join(User.dataset, user_id: :author_id)
    .where(flagged: 0, user_id: user_id)
    .order(Sequel.desc(:pub_date)).limit(no_msgs).all

  filtered_msgs(messages).to_json
end

# Logs the user in.
get "/login" do
  if @user
    redirect "/"
  end
  erb :login
end

post "/login" do
  if @user
    puts "User: #{@user} already logged in redirecting to /"
    # already logged in
    redirect "/"
  end

  puts "Username: #{params[:username]}"
  # get the user
  result = User.where(username: params[:username]).first

  if result.nil? || result.username.length <= 0
    @error = "Invalid username"

  elsif result.pw_hash == generate_pw_hash(params[:password])
    @user = result
    # set the session when the user is logged in
    session[:user] = @user.user_id
    # display a message
    flash[:notice] = "You were logged in"
    # redirect to the timeline
    puts "User: #{@user} logged in redirecting to /"
    redirect "/"
  else
    @error = "Invalid password"
  end
  # error message
  erb :login
end

# Displays the register form.
get "/register" do
  if @user
    redirect "/"
  end
  erb :register
end

def get_register_payload(request, is_simulator)
  if is_simulator
    body = JSON.parse request.body.read
    return {
      username: body["username"],
      email: body["email"],
      password: body["pwd"],
      password2: body["pwd"]
    }
  end

  {
    username: params[:username],
    email: params[:email],
    password: params[:password],
    password2: params[:password2]
  }
end

post "/register" do
  is_simulator = request.content_type == "application/json"
  payload = get_register_payload(request, is_simulator)
  username, email, password, password2 = payload.values_at(:username, :email, :password, :password2)

  if is_simulator
    update_latest(params, "POST /register")
  elsif @user
    redirect "/"
  end

  if !username || username == ""
    @error = "You have to enter a username"
  elsif email.nil? || !email.include?("@")
    @error = "You have to enter a valid email address"
  elsif !password || password == ""
    @error = "You have to enter a password"
  elsif !is_simulator && password != password2
    @error = "The two passwords do not match"
  elsif !get_user_id(username).nil?
    @error = "The username is already taken"
  else
    User.insert(username: username, email: email, pw_hash: generate_pw_hash(password))

    if is_simulator
      return status 204
    else
      flash[:notice] = "You were successfully registered and can login now"
      redirect "/login"
    end
  end

  if is_simulator
    halt 400, {status: 400, error_msg: @error}.to_json
  else
    erb :register
  end
end

# Logs the user out.
get "/logout" do
  puts "Logging out user: #{@user}"
  if session[:user] || @user
    session[:user] = nil
  end
  @user = nil
  flash[:notice] = "You were logged out"
  redirect "/public"
end

def follow(user_id, follows_username)
  follows_user_id = get_user_id(follows_username)
  user_not_found unless user_id && follows_user_id

  # check if the user is already following the user
  halt 400, "Already following" if Follower.where(who_id: user_id, whom_id: follows_user_id).first

  Follower.insert(who_id: user_id, whom_id: follows_user_id)
end

def unfollow(user_id, unfollows_username)
  unfollows_user_id = get_user_id(unfollows_username)
  user_not_found unless user_id && unfollows_user_id

  # make sure the user is following the user
  halt 400, "Not following" unless Follower.where(who_id: user_id, whom_id: unfollows_user_id).first

  Follower.where(who_id: user_id, whom_id: unfollows_user_id).delete
end

get "/:username/follow" do
  username = params[:username]
  follow(@user.user_id, username)

  flash[:notice] = "You are now following &#34;#{username}&#34;"
  redirect "/#{username}"
end

get "/:username/unfollow" do
  username = params[:username]
  unfollow(@user.user_id, username)

  flash[:notice] = "You are no longer following #{username}"
  redirect "/#{username}"
end

get "/fllws/:username" do
  update_latest(params, "GET /fllws")
  req_from_simulator = not_req_from_simulator(request)
  if req_from_simulator
    return req_from_simulator
  end
  user_id = get_user_id(params[:username])
  user_not_found unless user_id

  limit = params["no"] || 100
  follower_names = User.dataset.join(Follower.dataset, whom_id: :user_id).where(who_id: user_id).limit(limit).map(:username)

  {follows: follower_names}.to_json
end

post "/fllws/:username" do
  update_latest(params, "POST /fllws")
  req_from_simulator = not_req_from_simulator(request)
  if req_from_simulator
    return req_from_simulator
  end
  user_id = get_user_id(params[:username])
  user_not_found unless user_id

  body = JSON.parse request.body.read
  follows_username = body["follow"]
  unfollows_username = body["unfollow"]

  if follows_username
    follow(user_id, follows_username)
    return status 204
  elsif unfollows_username
    unfollow(user_id, unfollows_username)
    return status 204
  end
end

# Registers a new message for the user.
post "/add_message" do
  if !@user
    halt 401, "Unauthorized"
  end
  if params[:message]
    Message.insert(author_id: @user.user_id, text: Rack::Utils.escape_html(params[:message]), pub_date: Time.now.to_i, flagged: 0)
    flash[:notice] = "Your message was recorded"
  end
  redirect "/"
end

get "/latest" do
  # Fetch the latest id from the database
  latest_id = Request.select(:latest_id).first
  latest_id = latest_id ? latest_id.latest_id : -1

  {latest: latest_id}.to_json
end

get "/health" do
  "OK"
end

# Place this in bottom, because the routes are evaluated from top to bottom
# e.g. /:username would match /login or /logout
get "/:username" do
  username = params[:username]
  puts "Getting profile for user: #{username}"
  # # Fetch the user's profile from the database
  @profile_user = User.where(username: username).first
  user_not_found unless @profile_user
  puts "Getting profile_user: #{@profile_user}"

  @followed = false
  if @user
    @followed = !Follower.where(who_id: @user.user_id, whom_id: @profile_user.user_id).first.nil?
    puts "#{@user.username} Follows #{@profile_user.username}: #{@followed}"
  end

  page = params[:page].to_i
  page = 1 if page < 1
  @page = page

  max_page = (Message.dataset.join(User.dataset, user_id: :author_id).where(user_id: @profile_user.user_id).count / PER_PAGE.to_f).ceil
  max_page = 1 if max_page < 1
  @max_page = max_page

  offset = (page - 1) * PER_PAGE

  # # Fetch the user's messages from the database
  @messages = Message.dataset.join(User.dataset, user_id: :author_id).where(user_id: @profile_user.user_id)
    .order(Sequel.desc(:pub_date)).offset(offset).limit(PER_PAGE).all

  @has_more = @messages.size == PER_PAGE

  # Render the timeline template (timeline.erb)
  @show_follow_unfollow = true
  erb :timeline
end
