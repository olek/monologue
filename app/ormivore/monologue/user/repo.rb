module Monologue
  module User
    class Repo
      include ORMivore::Repo

      self.default_entity_class = Entity

      find :first, by: 'name'
    end
  end
end
