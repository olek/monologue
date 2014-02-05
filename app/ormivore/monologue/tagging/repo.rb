module Monologue
  module Tagging
    class Repo
      include ORMivore::Repo

      self.default_entity_class = Entity

      find :all, by: 'post_id'
    end
  end
end
