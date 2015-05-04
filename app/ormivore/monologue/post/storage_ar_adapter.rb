module Monologue
  module Post
    class StorageArAdapter
      include ORMivore::ArAdapter

      self.table_name = 'monologue_posts'

      def count_published_by_tag_ids(tag_ids)
        # NOTE those long table names here stink
        Hash[
          ar_class.connection.select_all(
            ar_class
              .select('tgn.tag_id as id, count(*) as count')
              .joins('inner join monologue_taggings as tgn on tgn.post_id = monologue_posts.id')
              .where('tgn.tag_id' => tag_ids)
              .where(published: true).where("published_at <= ?", DateTime.now)
              .group('tgn.tag_id')
          ).map { |h|
            [Integer(h['id']), Integer(h['count'])]
          }
        ]
      end
    end
  end
end
