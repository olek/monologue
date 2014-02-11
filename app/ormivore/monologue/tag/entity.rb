module Monologue
  module Tag
    class Entity
      include ORMivore::Entity

      attributes do
        string :name
      end
    end
  end
end
