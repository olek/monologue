require 'spec_helper'
describe "sessions" do
  let(:storage_session) { ORMivore::Session.new(Monologue::Repos, Monologue::Associations) }

  context "logged in user" do
    before(:each) do
      log_in
    end
    
    it "can log out" do
      visit admin_path
      click_link "Log out"
    end
  end
  
  context "NOT logged in user" do
    it "can log if password provided is valid" do
      log_in
    end

    it "won't log if bad credentials are provided" do
      user = FactoryGirl.build(:orm_user, session: storage_session)
      storage_session.commit

      visit admin_login_path
      fill_in "email", with:  user.email
      fill_in "Password", with:  "whatever"
      click_button "Log in"
      page.should have_content("Invalid email or password")
    end
  end  
end
