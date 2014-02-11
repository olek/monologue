module Monologue
  module User
    class StorageArAdapter
      include ORMivore::ArAdapter

      self.table_name = 'monologue_users'
    end
  end
end
