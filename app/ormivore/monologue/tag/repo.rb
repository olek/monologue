module Monologue
  module Tag
    class Repo
      include ORMivore::Repo

      find :all, order: { name: :ascending }

      find :all, by: 'name'

      def find_by_name(name)
        load_entity(
          port.find_by_case_insensitive_name(name, all_known_columns).first
        )
      end
    end
  end
end
