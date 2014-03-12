module Monologue
  module User
    class Repo
      include ORMivore::Repo

      find :all, limit: 300
      find :first, by: 'name'
    end
  end
end
