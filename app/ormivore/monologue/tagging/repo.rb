module Monologue
  module Tagging
    class Repo
      include ORMivore::Repo

      find :all, by: 'post_id'
    end
  end
end
