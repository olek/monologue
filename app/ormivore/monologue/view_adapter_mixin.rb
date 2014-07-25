module Monologue
  module ViewAdapterMixin
    module ClassMethods
      def entity(entity_class)
        entity_class.attributes_list.map(&:to_s).each do |attr|
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

      # keeping polymorphic_url route helper happy
      def model_name
        namespace = self.name.split('::')
        ActiveModel::Name.new(self, namespace.first.constantize, namespace[0..1].join('::'))
      end

      # just maintaining compatability with existing locale files
      def i18n_scope
        :activerecord
      end
    end

    def self.included(base)
      base.extend ActiveModel::Naming
      base.send(:include, ActiveModel::Validations)
      base.send(:include, ActiveModel::Conversion)
      base.send(:include, ActiveModel::MassAssignmentSecurity)
 
      base.extend ClassMethods
      # can not just have methods in ViewAdapterMixin module because
      # they have to be mixed in last, not first
      base.send(:include, InstanceMethods)
    end

    module InstanceMethods
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
        if valid?
          persist
          true
        else
          false
        end
      end

      # Now we need to handle case of partial rendering getting confused
      # with wrong class... love the consistency of rails...
      def to_partial_path
        model_name  = self.class.model_name
        "monologue/#{model_name.route_key}/#{model_name.singular_route_key}"
      end

      def ==(other)
        return entity == other.entity
      end

      protected

      attr_accessor :entity

      private

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
