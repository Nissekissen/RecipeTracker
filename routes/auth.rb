require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'google/apis/oauth2_v2'
require 'googleauth'
require 'googleauth/id_tokens'
require 'sinatra/namespace'
require 'sequel'

class MyApp < Sinatra::Application

  before do
    
    user_session = Session.find(token: cookies[:session])
    if !session.nil? && valid_session_token?(cookies[:session])
      @user = User.find(id: user_session.user_id)
    end
  end


  namespace '/auth' do

    get '/google' do
      db_session = Session[cookies[:session]]


      if db_session.nil?
        redirect settings.authorizer.get_authorization_url(request: request)
      end

      if !valid_session_token(db_session.token)
        redirect settings.authorizer.get_authorization_url(login_hint: db_session.user_id, request: request)
      end

      if params[:redirect] != nil
        redirect params[:redirect]
      else
        redirect '/'
      end
    end

    get '/google/callback' do
      credentials, redirect_uri = handle_auth_callback(request)

      access_token = credentials.access_token
      refresh_token = credentials.refresh_token
      expires_at = credentials.expires_at
      id_token = credentials.id_token

      payload = verify_and_decode_id_token(id_token)

      user_id = payload['sub']
      email = payload['email']

      db_user = User.where(email: email).first
      if db_user.nil?
        # create a new user
        user_info = Google::Apis::Oauth2V2::Oauth2Service.new.get_userinfo_v2(options: {authorization: credentials})
        db_user = User.create(name: user_info.name, email: user_info.email, avatar_url: user_info.picture)
      end

      if (db_session = Session.find(user_id: db_user.id))
        db_session.delete
      end

      # create new session
      session_token = generate_session_token(db_user.id)

      Session.create(user_id: db_user.id, token: session_token, expires_at: expires_at.to_i)

      cookies[:session] = session_token

      redirect '/'
    end

    get '/signin' do
      haml :'auth/signin'
    end

    get '/signout' do
      # delete the session
      session_token = cookies[:session]
      cookies.delete(:session)
      if !session_token.nil?
        Session.find(token: session_token).delete
      end
      redirect '/'
    end
  end

  get '/logout' do
    redirect '/auth/signout'
  end
end