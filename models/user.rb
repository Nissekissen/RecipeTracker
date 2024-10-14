

class User

  attr_accessor :id, :name, :email

  def initialize id, name, email
    @id = id
    @name = name
    @email = email
  end

  def self.from_hash hash
    return User.new(hash['id'], hash['name'], hash['email'])
  end

  def self.find db, id
    user = db.execute("SELECT * FROM users WHERE id = ?", id).first

    if user.nil?
      return nil
    else
      return User.from_hash(user)
    end
  end

  def self.create db, id, name, email
    db.execute("INSERT INTO users (id, name, email) VALUES (?, ?, ?)", id, name, email)
    return User.new(id, name, email)
  end

  def self.find_or_create db, id, name, email
    user = User.find(db, id)

    if user.nil?
      return User.create(db, id, name, email)
    else
      return user
    end
  end

  def to_hash
    return {
      'id' => @id,
      'name' => @name,
      'email' => @email
    }
  end

  def to_json
    return self.to_hash.to_json
  end

  def to_s
    return self.to_hash.to_s
  end
end