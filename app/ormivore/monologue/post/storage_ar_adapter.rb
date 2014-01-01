module Monologue
  module Post
    class StorageArAdapter
      include ORMivore::ArAdapter

      self.table_name = 'monologue_posts'
      self.default_converter_class = NoopStorageConverter
    end
  end
end
