module Monologue
  module Tagging
    class Entity
      include ORMivore::Entity

      attributes(
        post_id: Integer,
        tag_id: Integer
      )
    end
  end
end
