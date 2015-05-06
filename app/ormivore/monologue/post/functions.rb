module Monologue
  module Post
    module Functions
      def published_in_future?(entity)
        entity.published && entity.published_at > DateTime.now
      end

      def generate_url(entity)
        return entity unless entity.url.blank?
        return entity unless entity.title
        year = entity.published_at.class == ActiveSupport::TimeWithZone ? entity.published_at.year : DateTime.now.year
        url = "#{year}/#{entity.title.parameterize}"

        entity.apply(url: url)
      end

      extend self
    end
  end
end

