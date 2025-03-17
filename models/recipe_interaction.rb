require 'sequel'

class RecipeInteraction < Sequel::Model
  many_to_one :user
  many_to_one :recipe
end