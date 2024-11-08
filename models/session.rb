require 'sequel'

class Session < Sequel::Model(:sessions)
  many_to_one :user
end