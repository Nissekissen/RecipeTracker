require 'sequel'

class Tag < Sequel::Model
  many_to_one :recipe
end