require 'sinatra/content_for'
require 'sinatra/cookies'

class MyApp < Sinatra::Application
  # enable :sessions

  get '/' do
    haml :home
  end
end