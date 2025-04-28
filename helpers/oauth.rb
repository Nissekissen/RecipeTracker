require 'jwt'

AUTH_CODE_KEY = 'code'.freeze
SCOPE_KEY = 'scope'.freeze

module OAuth
  # Handles the authentication callback from Google.
  #
  # @param request [Sinatra::Request] The request object.
  # @return [Array] An array containing the credentials and the redirect URI.
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

  # Verifies and decodes the ID token from Google.
  #
  # @param id_token [String] The ID token.
  # @return [Hash] The payload of the ID token.
  # @raise [Sinatra::Halt] If the ID token is invalid or cannot be verified.
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

  # Generates a session token for the given user ID.
  #
  # @param user_id [Integer] The ID of the user.
  # @return [String] The session token.
  def generate_session_token user_id

    # generate token
    token = JWT.encode({ user_id: user_id}, settings.client_id.secret, 'HS256')
  end

  # Checks if a session token is valid for the given user ID.
  #
  # @param token [String] The session token.
  # @param user_id [Integer] The ID of the user.
  # @return [Boolean] True if the session token is valid, false otherwise.
  def is_valid_session_token? token, user_id
    begin
      decoded_token = JWT.decode token, settings.client_id.secret, true, { algorithm: 'HS256' }
      decoded_token.first['user_id'] == user_id
    rescue JWT::DecodeError
      false
    end
  end

  # Checks if a session token is valid.
  #
  # @param token [String] The session token.
  # @return [Boolean] True if the session token is valid, false otherwise.
  def valid_session_token? token
    begin
      JWT.decode token, settings.client_id.secret, true, { algorithm: 'HS256' }
      true
    rescue JWT::DecodeError
      false
    end
  end
  
end