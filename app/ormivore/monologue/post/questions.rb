module Monologue
  module Post
    module Questions
      def published_in_future?(entity)
        entity.published && entity.published_at > DateTime.now
      end

      extend self
    end
  end
end
