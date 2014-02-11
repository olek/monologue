module Monologue
  module Tag
    class Repo
      include ORMivore::Repo

      find :all, by: 'name'
    end
  end
end
