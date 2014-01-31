module Monologue
  module Tagging
    class Repo
      include ORMivore::Repo

      self.default_entity_class = Entity

      def find_all_by_post_id(post_id)
        entities_attrs = port.find(
          { post_id: post_id },
          columns_to_fetch
        )

        entities_attrs.map { |ea| attrs_to_entity(ea) }
      end
    end
  end
end
