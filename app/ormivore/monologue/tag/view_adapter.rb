module Monologue
  module Tag
    class ViewAdapter
      include ViewAdapterMixin

      entity Entity

      attr_accessible :name

      # TODO how to validate uniqueness?
      #validates :name, uniqueness: true,presence: true

      def posts_with_tag
        session.association(entity, :posts).select(&:published)
      end

      def frequency
        posts_with_tag.size
      end
    end
  end
end
