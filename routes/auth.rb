require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'google/apis/oauth2_v2'
require 'googleauth'
require 'googleauth/id_tokens'
require 'sinatra/namespace'

class MyApp < Sinatra::Application


  namespace '/auth' do

    get '/google' do
      user_id = session['user_id']
      client_id = settings.client_id.id

      if user_id.nil?
        redirect settings.authorizer.get_authorization_url(request: request)
      end

      credentials = settings.authorizer.get_credentials(user_id, request)
      if credentials.nil?
        redirect settings.authorizer.get_authorization_url(login_hint: user_id, request: request)
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

      db_user = User.find(db, user_id)

      if db_user.nil?
        # create a new user
        
        user_info = Google::Apis::Oauth2V2::Oauth2Service.new.get_userinfo_v2(fields: 'email,name', options: {authorization: credentials})

        db_user = User.create(db, user_id, user_info.name, user_info.email)
      end

      
    end

    get '/signin' do
      haml :'auth/signin'
    end

    get '/signout' do

    end
  end
end