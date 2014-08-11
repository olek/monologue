module Monologue
  module Post
    class Repo
      include ORMivore::Repo

      find :all, named: 'for_admin_listing' , order: { published_at: :descending, id: :descending }
      find :all, by: 'user_id'
      find :first, by: 'url'

      find :all, named: 'for_feed_listing',
        order: { published_at: :descending, id: :descending },
        # TODO how to filter by date (less than, greater than?)
        filter_by: { published: true, published_at: (DateTime.new(2000)..DateTime.now) },
        limit: 25

      find :all, named: 'recent',
        order: { published_at: :descending, id: :descending },
        # TODO how to filter by date (less than, greater than?)
        filter_by: { published: true, published_at: (DateTime.new(2000)..DateTime.now) },
        limit: 3

      paginate 'reader_listing',
        order: { published_at: :descending, id: :descending },
        # TODO how to filter by date (less than, greater than?)
        filter_by: { published: true, published_at: (DateTime.new(2000)..DateTime.now) },
        page_size: 10

      def count_published_by_tags(tags)
        port.count_published_by_tag_ids(tags.map(&:identity))
      end
    end
  end
end
