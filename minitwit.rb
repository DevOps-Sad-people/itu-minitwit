require 'sinatra'
require 'sqlite3'

# configuration
DATABASE = './tmp/minitwit.db'
PER_PAGE = 30
DEBUG = true
SECRET_KEY = 'development key development key development key development key development key development key development key'

configure do
    enable :sessions
    set :session_secret, SECRET_KEY
    set :show_exceptions, DEBUG
    set :views, File.join(File.dirname(__FILE__), 'templates')
    set :public_folder, __dir__ + '/public'
end

def connect_db
    puts "in connect_db"
    db = SQLite3::Database.new(DATABASE)
    db.results_as_hash = true
    db
end

def init_db
    puts "in init_db"
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
    puts "in get_user_id"
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

# before each request, make sure the database is connected
before do
    @db = connect_db
    @user = nil
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




set :port, 4567
set :bind, '0.0.0.0'

get '/frank-says' do
    'Put this in your pipe & smoke it!'
end