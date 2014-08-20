module Monologue
  module Tag
    class StoragePort
      include ORMivore::Port
      extend Forwardable

      def_delegator :adapter, :find_by_case_insensitive_name
    end
  end
end
