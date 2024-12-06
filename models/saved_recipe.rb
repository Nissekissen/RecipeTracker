require 'sequel'

class SavedRecipe < Sequel::Model(:saved_recipes)
  many_to_one :user
  many_to_one :recipe
  many_to_one :user_collection
end