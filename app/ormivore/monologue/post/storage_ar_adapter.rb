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
              .select('monologue_taggings.tag_id as id, count(*) as count')
              .joins('inner join monologue_taggings on monologue_taggings.post_id = monologue_posts.id')
              .where('monologue_taggings.tag_id' => tag_ids)
              .where(published: true).where("published_at <= ?", DateTime.now)
              .group('monologue_taggings.tag_id')
          ).map { |h|
            [Integer(h['id']), Integer(h['count'])]
          }
        ]
      end
    end
  end
end
