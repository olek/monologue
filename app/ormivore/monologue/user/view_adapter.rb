module Monologue
  module User
    class ViewAdapter
      include ViewAdapterMixin
      include ActiveModel::SecurePassword

      entity Entity

      attr_accessible :name, :email, :password, :password_confirmation

      has_secure_password

      validates_presence_of :password_confirmation, if: :password

      validates_presence_of :password, on: :create
      validates_presence_of :name
      # TODO how to validate uniqueness?
      validates :email , presence: true #, uniqueness: true

      def apply_sanitized_attributes(values)
        reject_list = %w(password password_confirmation).map(&:to_sym)
        super(values.reject { |k| reject_list.include?(k.to_sym) })
        # TODO allow easier assignment of transient attributes
        self.password = values[:password] || values['password']
        self.password_confirmation = values[:password_confirmation] || values['password_confirmation']
      end

      def posts
        session.association(entity, :posts).values.map { |o|
          Post::ViewAdapter.new(o)
        }
      end

      # TODO business logic does not belong here; find better place for it!
      def can_delete?(user)
        return false if self == user
        return false if user.posts.any?
        true
      end
    end
  end
end
