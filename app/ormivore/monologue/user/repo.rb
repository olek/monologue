module Monologue
  module User
    class Repo
      include ORMivore::Repo

      self.default_entity_class = Entity

      def find_by_name(name)
        entities_attrs = port.find(
          { name: name },
          [:id].concat(entity_class.attributes_list),
          limit: 1
        )
        entities_attrs.map { |ea| attrs_to_entity(ea) }.first
      end
    end
  end
end
