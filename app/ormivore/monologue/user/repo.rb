module Monologue
  module User
    class Repo
      include ORMivore::Repo

      find :all, limit: 300
      find :first, by: 'name'
      find :first, by: 'email'
    end
  end
end
