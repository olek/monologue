module Monologue
  module Post
    class Entity
      include ORMivore::Entity

      attributes(
        title: String,
        content: String,
        url: String,
        published: Boolean,
        published_at: Time,
      )

      many_to_one :user, User::Entity, fk: 'user_id'
      one_to_many :taggings, Tagging::Entity, fk: 'post_id'
      many_to_many :tags, Tag::Entity, through: 'taggings', fk: 'tag_id'

      responsibility :questions, Questions
      responsibility :actions, Actions
    end
  end
end
