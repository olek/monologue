module Monologue
  module Post
    class Questions
      def initialize(entity)
        @entity = entity
      end

      # NOTE result to any question can be memoized since entity never
      # changes - potential perfomance boost
      def published_in_future?
        entity.published && entity.published_at > DateTime.now
      end

      private
      attr_reader :entity
    end
  end
end
