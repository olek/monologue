module Monologue
  module Post
    class Associations
      extend ORMivore::Entity::AssociationsDSL

      many_to_one :user, User::Entity, fk: 'user_id'

      one_to_many :taggings, Tagging::Entity, fk: 'post_id'

      many_to_many :tags, Tag::Entity, through: 'taggings', fk: 'tag_id'
    end
  end
end
