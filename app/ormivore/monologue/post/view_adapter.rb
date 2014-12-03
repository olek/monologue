module Monologue
  module Post
    class ViewAdapter
      include ViewAdapterMixin

      entity Entity

      attr_accessible :title, :content, :url, :published, :published_at, :tag_list

      validates :user_id, presence: true
      validates :title, :content, :url, :published_at, presence: true
      # TODO how to validate uniqueness ?
      # validates :url, uniqueness: true
      validate :url_do_not_start_with_slash

      def tag_list
        if @tag_list
          @tag_list
        else
          tags = session.association(entity, :tags).values
          @tag_list = tags.map(&:name).join(', ')
        end
      end

      def tag_list=(value)
        @tag_list = value
      end

      def published_in_future?
        Questions.published_in_future?(entity)
      end

      def full_url
        "#{Monologue::Engine.routes.url_helpers.root_path}#{self.url}"
      end

      def user
        User::ViewAdapter.new(session.association(entity, :user).value)
      end

      def tags
        # limitation - new tags are not previewed
        session.association(entity, :tags).values.map { |t| Tag::ViewAdapter.new(t) }
      end

      def save
        generate_url
        super
      end

      private

      def apply_sanitized_attributes(values)
        super(values.reject { |k| k.to_sym == :tag_list })
        self.tag_list = values[:tag_list] if values[:tag_list]
      end

      def url_do_not_start_with_slash
        errors.add(:url, I18n.t("activerecord.errors.models.monologue/post.attributes.url.start_with_slash")) if url && url.start_with?("/")
      end

      def generate_url
        Actions.generate_url(entity)
      end

      def persist
        if tag_list
          if tag_list.empty?
            session.association(entity, :tags).clear
          else
            tag_names = tag_list.split(",").map(&:strip).reject(&:blank?)
            tag_repo = session.repo.tag
            existing_tags = tag_repo.find_all_by_name(tag_names)
            created_tags = tag_names.each_with_object([]) { |tag_name, acc|
              unless existing_tags.any? { |et| et.name == tag_name }
                acc << tag_repo.create(name: tag_name)
              end
            }
            new_tags = existing_tags + created_tags

            unless new_tags.empty?
              session.association(entity, :tags).set(*new_tags)
            end
          end
        end

        super
      end
    end
  end
end
