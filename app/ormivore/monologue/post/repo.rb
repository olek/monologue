module Monologue
  module Post
    class Repo
      include ORMivore::Repo

      self.default_entity_class = Entity

      def delete(post)
        # TODO not the most efficient way to destroy/delete taggings, may do in one query
        post.associations.taggings.each do |tagging|
          family[Tagging::Entity].delete(tagging)
        end

        super
      end

      def find_all_for_listing
        entities_attrs = port.find(
          {},
          columns_to_fetch,
          order: { published_at: :descending, id: :descending }
        )
        entities_attrs.map { |ea| attrs_to_entity(ea) }
      end

      def find_all_by_user_id(user_id)
        entities_attrs = port.find(
          { user_id: user_id },
          columns_to_fetch
        )
        entities_attrs.map { |ea| attrs_to_entity(ea) }
      end
    end
  end
end
