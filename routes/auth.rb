require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'google/apis/oauth2_v2'
require 'googleauth'
require 'googleauth/id_tokens'
require 'sinatra/namespace'
require 'sequel'

class MyApp < Sinatra::Application


  namespace '/auth' do

    get '/google' do
      _session = Session[session['token']]


      if _session.nil?
        redirect settings.authorizer.get_authorization_url(request: request)
      end

      if !UserSession.is_valid?(db, _session.token)
        redirect settings.authorizer.get_authorization_url(login_hint: _session.user_id, request: request)
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

      p payload

      user_id = payload['sub']
      email = payload['email']

      db_user = User.where(email: email).first

      if db_user.nil?
        # create a new user
        
        user_info = Google::Apis::Oauth2V2::Oauth2Service.new.get_userinfo_v2(options: {authorization: credentials})
        db_user = User.create(name: user_info.name, email: user_info.email, avatar_url: user_info.picture)
      end

      _session = Session.where(user_id: db_user.id).first

      if !_session.nil?
        Session.where(user_id: db_user.id).delete
      end

      # create new session
      session_token = generate_session_token(db_user.id)

      Session.create(user_id: db_user.id, token: session_token, expires_at: expires_at.to_i)

      session['token'] = session_token

      redirect '/'
    end

    get '/signin' do
      haml :'auth/signin'
    end

    get '/signout' do
      # delete the session
      session_id = session['token']
      if session_id && (session = Session.find(id: session_id))
        session.delete
        session['token'] = nil
      end

      redirect '/'
    end
  end
end