class Monologue::TagRecord < ActiveRecord::Base
  self.table_name = 'monologue_tags'

  # keeping polymorphic_url route helper happy
  def self.model_name
    ActiveModel::Name.new(self, Monologue, 'Monologue::Tag')
  end

  # Now we need to handle case of partial rendering getting confused
  # with wrong class... love the consistency of rails...
  def to_partial_path
    model_name  = self.class.model_name
    "monologue/#{model_name.route_key}/#{model_name.singular_route_key}"
  end

  attr_accessible :name

  validates :name, uniqueness: true,presence: true
  has_many :taggings, class_name: "Monologue::TaggingRecord", foreign_key: :tag_id
  has_many :posts, through: :taggings

  def posts_with_tag
    self.posts.published
  end

  def frequency
    posts_with_tag.size
  end
end
