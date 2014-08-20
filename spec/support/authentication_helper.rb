module MonologueSpecHelper
  module AuthenticationMock
    def sign_in_as user
      # TODO remove this madness after factories are sorted out
      id = user.respond_to?(:identity) ? user.identity : user.id
      session[:monologue_user_id] = id
    end
  end
end

RSpec.configure do |config|
  config.include MonologueSpecHelper::AuthenticationMock, type: :controller
end
