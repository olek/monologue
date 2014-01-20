module Monologue
  module Post
    class Entity
      include ORMivore::Entity

      attributes(
        title: String,
        content: String,
        url: String,
        published: Boolean,
        published_at: Time,
        user_id: Integer
      )

      # TODO come back to this defficiency later
      optional :title, :content, :url, :published, :published_at, :user_id

      def questions
        @questions ||= Questions.new(self)
      end

      def relations
        @relations ||= Relations.new(self)
      end

      def actions
        @actions ||= Actions.new(self)
      end
    end
  end
end
