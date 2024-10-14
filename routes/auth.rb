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
      user_id = session['user_id']
      user_id = 'default' if user_id.nil?
      credentials, redirect_uri = settings.authorizer.handle_auth_callback(user_id, request)

      if credentials.nil?
        redirect redirect_uri
      end

      # check if the user exists in the database
      user = User.find(db, user_id)

      if user.nil?
        # get the user info
        user_info = get_user_info(user_id)

        if !User.find(db, user_info[:id]).nil?
          p "User already exists with id: #{user_info[:id]}"

          session['user_id'] = user_info[:id]

          redirect '/'
        end

        p user_info

        # create the user
        user = User.create(db, user_info[:id], user_info[:name], user_info[:email])

        p "User created with id: #{user_info[:id]}"

      end
      
      
      redirect '/'
    end

    get '/signin' do
      @client_id = settings.client_id.id
      @login_uri = "/auth/google/callback"

      # check if the user is already signed in
      if is_signed_in?
        redirect '/'
      else
        haml :'auth/signin'
      end
    end

    get '/signout' do
      # clear storage
      settings.authorizer.clear_credentials(session['user_id'])

      # clear session
      session['user_id'] = nil

      redirect '/'
    end
  end
end