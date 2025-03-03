require 'sequel'
require 'securerandom'

class Recipe < Sequel::Model(:recipes)
  one_to_many :saved_recipes
  one_to_many :ingredients
  one_to_many :tags

  def before_create
    self.id = SecureRandom.hex(3).upcase
    super
  end
end