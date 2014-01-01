module Monologue
  module Tag
    class Repo
      include ORMivore::Repo

      self.default_entity_class = Entity
    end
  end
end
