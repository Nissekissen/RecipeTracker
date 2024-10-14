
class MyApp < Sinatra::Application
  enable :sessions

  before do
    # check if the user is signed in
    if is_signed_in?
      @user = User.find(db, session['user_id'])
      p "Signed in as: #{@user}"
    else
      p "Not signed in."
    end
  end

  get '/' do
    haml :home
  end
end