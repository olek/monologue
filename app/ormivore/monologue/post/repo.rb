module Monologue
  module Post
    class Repo
      include ORMivore::Repo

      find :all, order: { published_at: :descending, id: :descending }, named: 'for_listing'
      find :all, by: 'user_id'
    end
  end
end
