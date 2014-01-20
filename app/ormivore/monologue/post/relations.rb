module Monologue
  module Post
    class Relations
      def initialize(entity)
        @entity = entity
      end

      def user
        entity.repo.family[User::Entity].find_by_id(entity.user_id)
      end

      def tags
        entity.repo.family[Tag::Entity].find_all_by_post_id(entity.id)
      end

      private
      attr_reader :entity
    end
  end
end
