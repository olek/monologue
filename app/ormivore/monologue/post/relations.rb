module Monologue
  module Post
    class Relations
      include ORMivore::Entity::Relations

      memoize {
        def user
          entity.repo.family[User::Entity].find_by_id(entity.user_id)
        end

        def taggings
          entity.repo.family[Tagging::Entity].find_all_by_post_id(entity.id)
        end

        def tags
          entity.repo.family[Tag::Entity].find_all_by_post_id(entity.id)
        end
      }
    end
  end
end
