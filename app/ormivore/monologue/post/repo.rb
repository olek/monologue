module Monologue
  module Post
    class Repo
      include ORMivore::Repo

      def delete(post)
        # TODO not the most efficient way to destroy/delete taggings, may do in one query
        post.associations.taggings.each do |tagging|
          family[Tagging::Entity].delete(tagging)
        end

        super
      end

      find :all, order: { published_at: :descending, id: :descending }, named: 'for_listing'
      find :all, by: 'user_id'
    end
  end
end
