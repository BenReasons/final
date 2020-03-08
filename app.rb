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