module Monologue
  module Tagging
    class StorageArAdapter
      include ORMivore::ArAdapter

      self.table_name = 'monologue_taggings'
      self.default_converter_class = NoopStorageConverter
    end
  end
end
