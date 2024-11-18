require 'sequel'

class GroupRecipe < Sequel::Model(:group_recipes)
  many_to_one :group
  many_to_one :recipe
  many_to_one :user
end