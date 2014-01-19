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

      attr_entity(*Entity.attributes_declaration.keys)
      attr_entity :id

      attr_reader :entity

      attr_accessible :title, :content, :url, :published, :published_at, :tag_list

      validates :user_id, presence: true
      validates :title, :content, :url, :published_at, presence: true
      # TODO how to validate uniqueness ?
      # validates :url, uniqueness: true
      validate :url_do_not_start_with_slash

      def initialize(repo, entity = nil)
        @repo = repo
        @entity = entity || Entity.new({})
      end

      def tag_list
        if @tag_list
          @tag_list
        else
          taggings = repo.family[Tagging::Entity].find_all_by_post_id(entity.id)
          tags = repo.family[Tag::Entity].find_by_ids(taggings.map(&:tag_id).sort)
          @tag_list = tags.values.map(&:name).join(', ')
        end
      end

      def tag_list=(value)
        @tag_list = value
      end

      def persisted?
        !(self.id.nil?)
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

      attr_writer :entity
      attr_reader :repo

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
        self.entity = repo.persist(entity)
        repo.persist_tag_list(entity, tag_list) if tag_list
      end
    end
  end
end
