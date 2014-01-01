class Monologue::TaggingRecord < ActiveRecord::Base
  self.table_name = 'monologue_taggings'

  # keeping polymorphic_url route helper happy
  def self.model_name
    ActiveModel::Name.new(self, Monologue, 'Monologue::Taging')
  end

  # Now we need to handle case of partial rendering getting confused
  # with wrong class... love the consistency of rails...
  def to_partial_path
    model_name  = self.class.model_name
    "monologue/#{model_name.route_key}/#{model_name.singular_route_key}"
  end

  belongs_to :post, class_name: 'Monologue::PostRecord', foreign_key: :post_id
  belongs_to :tag, class_name: 'Monologue::TagRecord', foreign_key: :tag_id

  attr_accessible :tag_id
end
