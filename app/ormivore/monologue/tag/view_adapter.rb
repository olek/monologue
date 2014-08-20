module Monologue
  module Tag
    class ViewAdapter
      include ViewAdapterMixin

      entity Entity

      attr_accessible :name

      # transient attribute
      attr_writer :frequency

      def frequency
        @frequency or fail 'Frequency was never set on this tag adapter'
      end

      # TODO how to validate uniqueness?
      #validates :name, uniqueness: true,presence: true

      def posts_with_tag
        session.association(entity, :posts).values.select(&:published).map { |o|
          Post::ViewAdapter.new(o)
        }
      end
    end
  end
end
