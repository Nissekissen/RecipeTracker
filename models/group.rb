require 'sequel'

class Group < Sequel::Model
  many_to_many :users
  one_to_many :invites
end