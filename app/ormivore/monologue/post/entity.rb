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
        user_id: Integer
      )

      associations Associations

      responsibility :questions, Questions
      responsibility :actions, Actions
    end
  end
end
