require 'sequel'

class Recipe < Sequel::Model(:recipes)
  one_to_many :saved_recipes
  one_to_many :ingredients
  one_to_many :tags
end