module Monologue
  module Post
    class Repo
      include ORMivore::Repo

      find :all, named: 'for_admin_listing' , order: { published_at: :descending, id: :descending }
      find :all, named: 'for_reader_listing',
        order: { published_at: :descending, id: :descending },
        # TODO how to filter by date (less than, greater than?)
        filter_by: { published: true, published_at: (DateTime.new(2000)..DateTime.now) }
      find :all, named: 'for_feed_listing',
        order: { published_at: :descending, id: :descending },
        # TODO how to filter by date (less than, greater than?)
        filter_by: { published: true, published_at: (DateTime.new(2000)..DateTime.now) },
        limit: 25

      find :all, by: 'user_id'
      find :first, by: 'url'
    end
  end
end
