module Monologue
  module User
    class Entity
      include ORMivore::Entity

      attributes(
        name: String,
        email: String,
        password_digest: String
      )
    end
  end
end
