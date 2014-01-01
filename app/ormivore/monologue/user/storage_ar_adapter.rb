module Monologue
  module User
    class StorageArAdapter
      include ORMivore::ArAdapter

      self.table_name = 'monologue_users'
      self.default_converter_class = NoopStorageConverter
    end
  end
end
