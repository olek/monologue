require 'spec_helper'
module LoginHelpers
  def log_in (user=nil)
    # TODO do not use ar factory here
    user ||= FactoryGirl.create(:user)
    visit admin_login_path
    fill_in "email", with:  user.email
    # TODO figure out how to pass user's password here...
    password = user.respond_to?(:password) ? user.password : 'password'
    fill_in "Password", with: password #user.password
    click_button "Log in"
    page.should have_content("Logged in!")
  end

  def log_out
    visit admin_path
    click_link "logout"
    page.should have_content("Logged out!")
  end
end

RSpec.configure do |c|
  c.include LoginHelpers, type: :request
end
