module Monologue
  module Tag
    class StorageArAdapter
      include ORMivore::ArAdapter

      self.table_name = 'monologue_tags'
    end
  end
end
