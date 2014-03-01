module Monologue
  module Post
    class Entity
      include ORMivore::Entity

      shorthand :post

      attributes do
        string :title, :content, :url
        boolean :published
        time :published_at
        integer :user_id
      end

      #many_to_one :user, User::Entity, fk: 'user_id'
      #one_to_many :taggings, Tagging::Entity, inverse_of: :post
      #many_to_many :tags, Tag::Entity, through: 'taggings', source: 'tag'

      responsibility :questions, Questions
      responsibility :actions, Actions
    end
  end
end
