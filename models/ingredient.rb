require 'sequel'

class Ingredient < Sequel::Model
  many_to_one :recipe
end