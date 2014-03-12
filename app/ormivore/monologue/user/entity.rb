module Monologue
  module User
    class Entity
      include ORMivore::Entity

      shorthand :user

      attributes do
        string :name, :email, :password_digest
      end
    end
  end
end
