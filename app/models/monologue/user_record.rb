class Monologue::UserRecord < ActiveRecord::Base
  self.table_name = 'monologue_users'

  # keeping polymorphic_url route helper happy
  def self.model_name
    ActiveModel::Name.new(self, Monologue, 'Monologue::User')
  end

  # Now we need to handle case of partial rendering getting confused
  # with wrong class... love the consistency of rails...
  def to_partial_path
    model_name  = self.class.model_name
    "monologue/#{model_name.route_key}/#{model_name.singular_route_key}"
  end

  has_many :posts, class_name: "Monologue::PostRecord", foreign_key: :user_id

  attr_accessible :name, :email, :password, :password_confirmation

  has_secure_password

  validates_presence_of :password, on: :create
  validates_presence_of :name
  validates :email , presence: true, uniqueness: true


  def can_delete?(user)
    return false if self==user
    return false if user.posts.any?
    true
  end
end
