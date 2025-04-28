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
      @jwt = user_session.token
    end
  end

  error 401 do
    redirect '/auth/sign-in?redirect=' + request.path
  end


  namespace '/auth' do

    # log in with google
    get '/google' do
      db_session = Session[cookies[:session]]

      redirect_url = params[:redirect]
      cookies[:redirect] = redirect_url if redirect_url


      if db_session.nil?
        redirect settings.authorizer.get_authorization_url(request: request)
      end

      if !valid_session_token(db_session.token)
        redirect settings.authorizer.get_authorization_url(login_hint: db_session.user_id, request: request)
      end

      redirect '/' if !redirect_url.nil?
      redirect redirect_url 
    end

    get '/google/callback' do
      credentials, redirect_uri = handle_auth_callback(request)
      # Exchange the authorization code for credentials
      # credentials = settings.authorizer.get_and_store_credentials_from_code(request: request, code: code, redirect_uri: 'http://localhost:9292/auth/google/callback')
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
        
        # create default collection
        Collection.create(owner_id: db_user.id, name: 'Favoriter')
      end


      if (db_session = Session.find(user_id: db_user.id))
        db_session.delete
      end

      # create new session
      session_token = generate_session_token(db_user.id)
      Session.create(user_id: db_user.id, token: session_token, expires_at: expires_at.to_i)

      cookies[:session] = session_token
      

      if !cookies[:redirect].nil?
        redirect_url = cookies[:redirect]
        
        cookies.delete(:redirect)
        redirect redirect_url
      end

      redirect '/'  
        
    end

    # main login page
    get '/sign-in' do
      @redirect = params[:redirect]
      if @redirect.nil?
          @redirect = '/'
      end

      if !@user.nil?
        redirect @redirect
      end
      
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

  # GET /logout
  #
  # Redirects to the signout route.
  get '/logout' do
    redirect '/auth/signout'
  end

  namespace '/api/v1' do

    # GET /api/v1/get-user
    #
    # Returns the current user as JSON.
    #
    # @return [JSON] The current user.
    get '/get-user' do        
      # get user from jwt
      if @user.nil?
        halt 401, { error: 'Unauthorized' }.to_json
      end
      
      user = {
        id: @user.id,
        name: @user.name,
        avatar_url: @user.avatar_url
      }

      user.to_json
    end
  end
end