module Monologue
  module Tag
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

      def initialize(entity)
        @entity = entity
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

      # keeping polymorphic_url route helper happy
      def self.model_name
        ActiveModel::Name.new(self, Monologue, 'Monologue::Tag')
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

      # Now, variable part

      attr_accessible :name

      # TODO how to validate uniqueness?
      #validates :name, uniqueness: true,presence: true

      def posts_with_tag
        session.association(entity, :posts).select(&:published)
      end

      def frequency
        posts_with_tag.size
      end

      private

      attr_accessor :entity

      def session
        entity.session
      end

      def apply_sanitized_attributes(values)
        self.entity = entity.apply(values)
      end

      def persist
        session.commit

        self.entity = entity.current
      end
    end
  end
end

