module Monologue
  module Post
    class StoragePort
      include ORMivore::Port

      def count_published_by_tag_ids(tag_ids)
        adapter.count_published_by_tag_ids(tag_ids)
      end
    end
  end
end
