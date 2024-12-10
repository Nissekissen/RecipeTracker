require 'sinatra/content_for'
require 'sinatra/cookies'

class MyApp < Sinatra::Application
  # enable :sessions

  get '/' do
    haml :home
  end

  not_found do
    haml :'errors/not_found'
  end
end