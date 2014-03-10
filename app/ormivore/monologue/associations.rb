module Monologue
  class Associations
    extend ORMivore::Association::AssociationDefinitions

    association do
      from Post::Entity
      to User::Entity
      as :user
      reverse_as :many, :posts
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
      reverse_as :many, :taggings
    end

    transitive_association do
      from Post::Entity
      to Tag::Entity
      as :tags
      via :incidental, :taggings
      linked_by :tag
    end

    transitive_association do
      from Tag::Entity
      to Post::Entity
      as :posts
      via :incidental, :taggings
      linked_by :post
    end
  end
end
