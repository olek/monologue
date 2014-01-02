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

      def questions
        @questions ||= Questions.new(self)
      end

=begin
      # keeping polimorphic_url route helper happy
      def self.model_name
        ActiveModel::Name.new(self, Monologue, 'Monologue::Post')
      end

      # Now we need to handle case of partial rendering getting confused
      # with wrong class... love the consistency of rails...
      def to_partial_path
        model_name  = self.class.model_name
        "monologue/#{model_name.route_key}/#{model_name.singular_route_key}"
      end
=end
    end
  end
end
