require 'sequel'

class Invite < Sequel::Model
  many_to_one :group
  many_to_one :user
end
