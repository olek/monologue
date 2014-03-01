module Monologue
  class Associations
    extend ORMivore::Association::AssociationDefinitions

    association do
      from Post::Entity
      to User::Entity
      as :user
      reverse_as :many, :posts
    end

    transitive_association do
      from Post::Entity
      to Tag::Entity
      as :tags
      via :taggings
      linked_by :tag
    end

    association do
      from Tagging::Entity
      to Post::Entity
      as :post
      reverse_as :many, :taggings
    end

    association do
      from Tagging::Entity
      to Tag::Entity
      as :tag
    end
  end
end
