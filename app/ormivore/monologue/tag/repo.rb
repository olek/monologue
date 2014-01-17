module Monologue
  module Tag
    class Repo
      include ORMivore::Repo

      self.default_entity_class = Entity

      def find_all_by_names(names)
        entities_attrs = port.find(
          { name: names },
          [:id].concat(entity_class.attributes_list)
        )
        entities_attrs.map { |ea| attrs_to_entity(ea) }
      end
    end
  end
end
