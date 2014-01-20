module Monologue
  module Tag
    class Repo
      include ORMivore::Repo

      self.default_entity_class = Entity

      def find_all_by_name(name)
        entities_attrs = port.find(
          { name: name },
          [:id].concat(entity_class.attributes_list)
        )
        entities_attrs.map { |ea| attrs_to_entity(ea) }
      end

      def find_all_by_post_id(post_id)
        # TODO optimize by using join and only one query if it is worth it
        taggings = family[Tagging::Entity].find_all_by_post_id(post_id)
        find_by_ids(taggings.map(&:tag_id).sort).values
      end
    end
  end
end
