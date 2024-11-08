require 'sequel'

class User < Sequel::Model(:users)
  one_to_many :sessions
  one_to_many :saved_recipes
end