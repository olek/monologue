module Monologue
  module Post
    class Repo
      include ORMivore::Repo

      self.default_entity_class = Entity
    end
  end
end
