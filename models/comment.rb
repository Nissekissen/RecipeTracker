require 'sequel'

class Comment < Sequel::Model
  many_to_one :recipe
  many_to_one :owner, class: :User
  many_to_one :parent, class: self
  many_to_one :group

  def before_create
    super
    self.created_at = Time.now
  end

  def validate
    super
    errors.add(:content, 'cannot be empty') if content.nil? || content.empty?
  end
end