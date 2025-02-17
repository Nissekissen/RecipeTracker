require 'sequel'

class Collection < Sequel::Model
  many_to_one :user
  one_to_many :saved_recipes
  many_to_one :group
end