require 'sequel'

class Group < Sequel::Model
  many_to_many :users
  one_to_many :invites
  one_to_many :group_recipes
end