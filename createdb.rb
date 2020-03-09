# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
DB.create_table! :stores do
  primary_key :id
  String :store_name
  String :description
  String :neighborhood
  String :address
  String :website
  String :phone_number
end
DB.create_table! :reviews do
    primary_key :id
    foreign_key :store_id
    foreign_key :user_id
    String :user_name
    Float :rating
    String :known_for
    String :comments, text: true
end
DB.create_table! :users do
  primary_key :id
  String :name
  String :email
  String :password
end

# Seed Data
stores_table = DB.from(:stores)

stores_table.insert(store_name: "Barnes & Noble - Gold Coast",
                    description: "Bookseller chain stocking housebrand eReader, plus a broad selection of titles for adults & kids.",
                    neighborhood: "Gold Coast",
                    address: "1130 North State Street",
                    website: "https://stores.barnesandnoble.com/store/2922",
                    phone_number: "(312) 280-8155")

stores_table.insert(store_name: "Volumes",
                    description: "Family-run shop with a handpicked selection of titles & a sit-down space for espresso, beer & wine.",
                    neighborhood: "Gold Coast",
                    address: "900 North Michigan Avenue",
                    website: "https://www.volumesbooks.com/",
                    phone_number: "(312) 846-6750")

stores_table.insert(store_name: "after-words bookstore",
                    description: "Independent bookstore offering a wide selection of new & used titles in vast, industrial-chic digs.",
                    neighborhood: "Streeterville",
                    address: "23 East Illinois Street",
                    website: "http://www.after-wordschicago.com/",
                    phone_number: "(312) 464-1110")