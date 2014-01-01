module Monologue
  module Tag
    class Entity
      include ORMivore::Entity

      attributes(
        name: String
      )
    end
  end
end
