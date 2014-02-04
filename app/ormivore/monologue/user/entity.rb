module Monologue
  module User
    class Entity
      include ORMivore::Entity

      attributes(
        name: String,
        email: String,
        password_digest: String
      )

      one_to_many :posts, Post::Entity, inverse_of: :user
    end
  end
end
