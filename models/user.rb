require 'sequel'
require 'securerandom'

class User < Sequel::Model(:users)
  one_to_many :sessions
  one_to_many :saved_recipes
  many_to_many :groups

  def before_create
    self.id ||= generate_hex_key
    super
  end

  def generate_hex_key
    SecureRandom.hex(6)
  end
end