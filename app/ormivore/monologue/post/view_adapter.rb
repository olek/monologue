module Monologue
  module Post
    class ViewAdapter
      extend ActiveModel::Naming
      include ActiveModel::Validations
      include ActiveModel::Conversion
      include ActiveModel::MassAssignmentSecurity

      def self.attr_entity(*attrs)
        attrs.map(&:to_s).each do |attr|
          module_eval(<<-EOS)
            def #{attr}
              entity.#{attr}
            end
            def #{attr}=(value)
              self.entity = entity.apply(#{attr}: value)
            end
          EOS
        end
      end

      attr_entity(*Entity.attributes_list)
      attr_entity :user_id

      def id
        entity.identity
      end

      attr_accessible :title, :content, :url, :published, :published_at, :tag_list

      validates :user_id, presence: true
      validates :title, :content, :url, :published_at, presence: true
      # TODO how to validate uniqueness ?
      # validates :url, uniqueness: true
      validate :url_do_not_start_with_slash

      def initialize(entity)
        @entity = entity
      end

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

      def persisted?
        entity.durable? || entity.revised?
      end

      def update_attributes(values, options = {})
        assign_attributes(values, options)

        save
      end

      def assign_attributes(values, options = {})
        apply_sanitized_attributes(sanitize_for_mass_assignment(values, options[:as]))
      end

      def save
        generate_url

        if valid?
          persist
          true
        else
          false
        end
      end

      def published_in_future?
        entity.questions.published_in_future?
      end

      def full_url
        "#{Monologue::Engine.routes.url_helpers.root_path}#{self.url}"
      end

      def user
        # TODO shall use User::ViewAdapter around user_id
        Monologue::UserRecord.find(user_id)
      end

      def tags
        # limitation - new tags are not previewed
        tag_names = tag_list.split(",").map(&:strip).reject(&:blank?)
        # TODO shall use User::TagAdapter
        #tag_repo = post_repo.family[Tag::Entity]
        #@tags = tag_names.empty? ?  [] : tag_repo.find_all_by_name(tag_names).map { |t| Tag::ViewAdapter.new(t) }
        tag_names.empty? ?  [] : TagRecord.find_all_by_name(tag_names)
      end

      # keeping polymorphic_url route helper happy
      def self.model_name
        ActiveModel::Name.new(self, Monologue, 'Monologue::Post')
      end

      # just maintaining compatability with existing locale files
      def self.i18n_scope
        :activerecord
      end

      # Now we need to handle case of partial rendering getting confused
      # with wrong class... love the consistency of rails...
      def to_partial_path
        model_name  = self.class.model_name
        "monologue/#{model_name.route_key}/#{model_name.singular_route_key}"
      end

      private

      attr_accessor :entity

      def session
        entity.session
      end

      def url_do_not_start_with_slash
        errors.add(:url, I18n.t("activerecord.errors.models.monologue/post.attributes.url.start_with_slash")) if url && url.start_with?("/")
      end

      def apply_sanitized_attributes(values)
        self.entity = entity.apply(values.reject { |k| k.to_sym == :tag_list })
        self.tag_list = values[:tag_list] if values[:tag_list]
      end

      def generate_url
        self.entity = entity.actions.generate_url
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

        session.commit

        self.entity = entity.current
      end
    end
  end
end
