module Monologue
  module Tag
    class Repo
      include ORMivore::Repo

      self.default_entity_class = Entity

      find :all, by: 'name'
    end
  end
end
