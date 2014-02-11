module Monologue
  module User
    class Repo
      include ORMivore::Repo

      find :first, by: 'name'
    end
  end
end
