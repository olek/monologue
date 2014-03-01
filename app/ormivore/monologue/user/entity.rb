module Monologue
  module User
    class Entity
      include ORMivore::Entity

      shorthand :user

      attributes do
        string :name, :email, :password_digest
      end

      #one_to_many :posts, Post::Entity, inverse_of: :user
    end
  end
end
