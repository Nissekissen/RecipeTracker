
module OAuth
  def get_user_info user_id
    client = Google::Apis::Oauth2V2::Oauth2Service.new
    credentials = settings.authorizer.get_credentials(user_id, request)
    client.authorization = credentials

    user_info = client.get_userinfo_v2.to_h


    # if the user_id is 'default', then replace 'default' with the actual user_id and save it to storage
    if user_id == 'default'
      user_id = user_info[:id]
      session['user_id'] = user_id
      settings.authorizer.store_credentials(user_id, credentials)
    end

    return user_info.to_h
  end

  def is_signed_in?
    return !session['user_id'].nil?
  end
end