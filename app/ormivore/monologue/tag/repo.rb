module Monologue
  module Tag
    class Repo
      include ORMivore::Repo

      find :all, by: 'name'
      find :first, by: 'name'

      find :all, order: { name: :ascending }
    end
  end
end
