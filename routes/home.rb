
class MyApp < Sinatra::Application
  enable :sessions

  before do
    # check if the user is signed in
    
  end

  get '/' do
    haml :home
  end
end