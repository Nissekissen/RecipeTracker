
class UserSession
  attr_accessor :user_id, :token, :expires_at, :session_id

  def initialize user_id, token, expires_at, session_id = nil
    @user_id = user_id
    @token = token
    @expires_at = expires_at
    @session_id = session_id
  end

  def self.from_hash hash
    UserSession.new(hash['user_id'], hash['token'], hash['expires_at'], hash['session_id'])
  end

  def self.find db, session_id
    _session = db.execute("SELECT * FROM sessions WHERE session_id = ?", session_id).first

    if _session.nil?
      return nil
    else
      return UserSession.from_hash(_session)
    end
  end

  def self.find_by_token db, token
    _session = db.execute("SELECT * FROM sessions WHERE token = ?", token).first

    if _session.nil?
      return nil
    else
      return UserSession.from_hash(_session)
    end
  end

  def self.create db, user_id, token, expires_at
    db.execute("INSERT INTO sessions (user_id, token, expires_at) VALUES (?, ?, ?)", user_id, token, expires_at)
    return UserSession.new(user_id, token, expires_at, db.last_insert_row_id)
  end

  def to_hash
    return {
      'user_id' => @user_id,
      'token' => @token,
      'expires_at' => @expires_at,
      'session_id' => @session_id
    }
  end

  def to_json
    return self.to_hash.to_json
  end

  def to_s
    return self.to_hash.to_s
  end
  
end