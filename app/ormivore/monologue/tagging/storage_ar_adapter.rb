module Monologue
  module Tagging
    class StorageArAdapter
      include ORMivore::ArAdapter

      self.table_name = 'monologue_taggings'
    end
  end
end
