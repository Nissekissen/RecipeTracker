require 'sequel'

class UserCollection < Sequel::Model
  many_to_one :user
  one_to_many :saved_recipes
end