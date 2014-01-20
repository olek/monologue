module Monologue
  module Post
    class Actions
      def initialize(entity)
        @entity = entity
      end

      def generate_url
        return entity unless entity.url.blank?
        return entity unless entity.title
        year = entity.published_at.class == ActiveSupport::TimeWithZone ? entity.published_at.year : DateTime.now.year
        url = "#{year}/#{entity.title.parameterize}"

        entity.apply(url: url)
      end

      private
      attr_reader :entity
    end
  end
end
