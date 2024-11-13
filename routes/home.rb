require 'sinatra/content_for'

class MyApp < Sinatra::Application
  enable :sessions

  before do
    # check if the user is signed in
    # p session['token']

    _session = Session.find(token: session['token'])
    if !_session.nil? && valid_session_token?(session['token'])
      @user = User.find(id: _session.user_id)
    end
  end

  get '/' do
    haml :home
  end
end