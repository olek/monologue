module Monologue
  module Tag
    class Entity
      include ORMivore::Entity

      shorthand :tag

      attributes do
        string :name
      end
    end
  end
end
