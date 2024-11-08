
require 'sinatra'
require 'haml'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'sequel'

# Haml::Template.options[:hyphenate_data_attrs] = false

class MyApp < Sinatra::Application
    enable :sessions



    configure do
    
      set :client_id, Google::Auth::ClientId.from_file('client_secret.json')
      set :scope, 'https://www.googleapis.com/auth/userinfo.profile'
      set :token_store, Google::Auth::Stores::FileTokenStore.new(file: 'tokens.yaml')
      set :authorizer, Google::Auth::WebUserAuthorizer.new(settings.client_id, settings.scope, settings.token_store, 'http://localhost:9292/auth/google/callback')
      
      set :haml, { :hyphenate_data_attrs => false }

      DB = Sequel.sqlite('db/development.sqlite3')
    end

    def db
        return @db if @db
  
        @db = SQLite3::Database.new("db/recipes.sqlite")
        @db.results_as_hash = true
  
        return @db
    end
end

require_relative 'helpers/init'
require_relative 'models/init'
require_relative 'routes/init'
