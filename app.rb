# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "bcrypt"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

stores_table = DB.from(:stores)
reviews_table = DB.from(:reviews)
users_table = DB.from(:users)

before do
    @current_user = users_table.where(id: session["user_id"]).to_a[0]
end

get "/" do
    puts stores_table.all
    @stores = stores_table.all.to_a
    view "stores"
end

get "/stores/:id" do
    @store = stores_table.where(id: params[:id]).to_a[0]
    @reviews = reviews_table.where(store_id: @store[:id])
    # @going_count = rsvps_table.where(event_id: @event[:id], going: true).count
    # @users_table = users_table
    view "store"
end


get "/stores/:id/reviews/new" do
    @store = stores_table.where(id: params[:id]).to_a[0]
    view "new_review"
end

get "/stores/:id/reviews/create" do
    puts params
    @store = stores_table.where(id: params["id"]).to_a[0]
    reviews_table.insert(store_id: params["id"],
                       user_name: session["user_name"],
                       rating: session["rating"],
                       known_for: session["known_for"],
                       comments: params["comments"])
    view "create_review"
end

get "/users/new" do
    view "new_user"
end

post "/users/create" do
    puts params
    hashed_password = BCrypt::Password.create(params["password"])
    users_table.insert(name: params["name"], email: params["email"], password: hashed_password)
    view "create_user"
end

get "/logins/new" do
    view "new_login"
end

post "/logins/create" do
    user = users_table.where(email: params["email"]).to_a[0]
    puts BCrypt::Password::new(user[:password])
    if user && BCrypt::Password::new(user[:password]) == params["password"]
        session["user_id"] = user[:id]
        @current_user = user
        view "create_login"
    else
        view "create_login_failed"
    end
end

get "/logout" do
    session["user_id"] = nil
    @current_user = nil
    view "logout"
end