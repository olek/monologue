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
          [:id].concat(entity_class.attributes_list),
          order: { published_at: :descending, id: :descending }
        )
        entities_attrs.map { |ea| attrs_to_entity(ea) }
      end

      def persist_tag_list(post, tag_list)
        # TODO need proper way to figure out if entity is persisted yet
        raise ORMivore::StorageError, "Post not persisted yet" unless post.id

        tag_names = tag_list.split(",").map(&:strip).reject(&:blank?)
        found_tags = tag_repo.find_all_by_name(tag_names)
        created_tags = (tag_names - found_tags.map(&:name)).map { |tn|
          tag_repo.persist(Tag::Entity.new.apply(name: tn))
        }

        tagging_join_table.associate(post, found_tags + created_tags)
      end

      private

      def tagging_join_table
        @tagging_join_table ||= JoinTable.new(
          repo: tagging_repo,
          entity_class: Tagging::Entity,
          this_fk: :post_id,
          other_fk: :tag_id
        )
      end

      # TODO JoinTable probably should be defined in ORMivore, specialized in Tagging::Entity.associations, and created here
      class JoinTable
        def initialize(options)
          @repo = options.fetch(:repo)
          @entity_class = options.fetch(:entity_class)
          @this_fk = options.fetch(:this_fk)
          @other_fk = options.fetch(:other_fk)
        end

        def associate(this, new_joinees)
          # assuming here that all join repos have those finder methods defined
          current_joins = repo.public_send("find_all_by_#{this_fk}", this.id)

          already_associated_joinees =
            current_joins.map { |current_join|
              matching_joinee = new_joinees.detect { |new_joinee| current_join.attributes[other_fk] == new_joinee.id }
              repo.delete(current_join) unless matching_joinee
              matching_joinee
            }.compact

          joinee_to_associate = new_joinees - already_associated_joinees

          joinee_to_associate.each do |joinee|
            repo.persist(entity_class.new.apply(this_fk => this.id, other_fk => joinee.id))
          end
        end

        private

        attr_reader :repo, :entity_class, :this_fk, :other_fk
      end

      def tag_repo
        family[Tag::Entity]
      end

      def tagging_repo
        family[Tagging::Entity]
      end
    end
  end
end
