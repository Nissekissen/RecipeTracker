require 'jwt'

AUTH_CODE_KEY = 'code'.freeze
SCOPE_KEY = 'scope'.freeze

module OAuth
  def handle_auth_callback request
    callback_state, redirect_uri = Google::Auth::WebUserAuthorizer.extract_callback_state(request)
    Google::Auth::WebUserAuthorizer.validate_callback_state callback_state, request
    
    credentials = settings.authorizer.get_credentials_from_code(
      code: callback_state[AUTH_CODE_KEY],
      scope: callback_state[SCOPE_KEY],
      base_url: request.url
    )

    [credentials, redirect_uri]
  end

  def verify_and_decode_id_token id_token
    begin
      payload = Google::Auth::IDTokens.verify_oidc id_token
    rescue Google::Auth::IDTokens::VerificationError => e
      halt 401, "Invalid ID token: #{e.message}"
    rescue Google::Auth::IDTokens::KeySourceErrr => e
      halt 500, "Unable to verify ID token: #{e.message}"
    end

    payload
    
  end

  def generate_new_session user_id

    # generate token
    token = JWT.encode({ user_id: user_id}, settings.secret, 'HS256')
  end
end