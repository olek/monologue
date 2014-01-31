module Monologue
  module Tag
    class Repo
      include ORMivore::Repo

      self.default_entity_class = Entity

      def find_all_by_name(name)
        entities_attrs = port.find(
          { name: name },
          columns_to_fetch
        )
        entities_attrs.map { |ea| attrs_to_entity(ea) }
      end
    end
  end
end
