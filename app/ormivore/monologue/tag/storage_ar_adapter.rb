module Monologue
  module Tag
    class StorageArAdapter
      include ORMivore::ArAdapter

      self.table_name = 'monologue_tags'

      def find_by_case_insensitive_name(name, attributes_to_load)
        ActiveRecord::Base.connection.select_all(
          ar_class.
            select(converter.attributes_list_to_storage(attributes_to_load)).
            where("lower(name) = ?", name.downcase).
            limit(1)
        ).map { |r| entity_attributes(r) }
      end
    end
  end
end
