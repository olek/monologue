module Monologue
  module Tag
    class StorageArAdapter
      include ORMivore::ArAdapter

      self.table_name = 'monologue_tags'
      self.default_converter_class = NoopStorageConverter
    end
  end
end
