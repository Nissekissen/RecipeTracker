require 'sequel'

class Group < Sequel::Model
  many_to_many :users
  one_to_many :invites
  one_to_many :collections
  one_to_many :saved_recipes
end