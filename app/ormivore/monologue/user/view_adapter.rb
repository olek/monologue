module Monologue
  module User
    class ViewAdapter
      include ViewAdapterMixin
      include ActiveModel::SecurePassword

      entity Entity

      attr_accessible :name, :email, :password, :password_confirmation

      has_secure_password

      validates_presence_of :password, on: :create
      validates_presence_of :name
      # TODO how to validate uniqueness?
      validates :email , presence: true #, uniqueness: true

      def can_delete?(user)
        return false if self==user
        return false if session.association(user, :posts).values.any?
        true
      end
    end
  end
end
