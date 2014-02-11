module Monologue
  module Post
    class StorageArAdapter
      include ORMivore::ArAdapter

      self.table_name = 'monologue_posts'
    end
  end
end
