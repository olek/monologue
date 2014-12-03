module Monologue
  module Post
    class Entity
      include ORMivore::Entity

      shorthand :post

      attributes do
        string :title, :content, :url
        boolean :published
        time :published_at
        integer :user_id
      end
    end
  end
end
