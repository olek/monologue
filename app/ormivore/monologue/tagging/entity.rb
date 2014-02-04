module Monologue
  module Tagging
    class Entity
      include ORMivore::Entity

      one_to_one :post, Post::Entity, fk: 'post_id', inverse_of: :taggings
      one_to_one :tag, Tag::Entity, fk: 'tag_id'
    end
  end
end
