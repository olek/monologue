module Monologue
  module Tagging
    class Entity
      include ORMivore::Entity

      shorthand :tagging

      attributes do
        integer :post_id
        integer :tag_id
      end
    end
  end
end
