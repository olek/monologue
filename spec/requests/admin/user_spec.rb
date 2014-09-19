# encoding: UTF-8
require 'spec_helper'
describe "users" do
  let!(:user) { FactoryGirl.build(:orm_user, session: storage_session) }
  let(:user_model) { Monologue::User::ViewAdapter.new(user.current) }
  let(:storage_session) { ORMivore::Session.new(Monologue::Repos, Monologue::Associations) }

  before do
    storage_session.commit
    log_in user.current
    #puts "DDDDDD: pd = #{user.password_digest}"
  end

  it "make sure the link to user edit screen is present", js: true, driver: :webkit do
    click_link I18n.t("layouts.monologue.admin.nav_bar.edit_user_info")
  end

  context "edit" do
    before do
      visit edit_admin_user_path(user_model)
    end

    it "validates user name is present" do
      fill_in "user_name", with: ""
      click_button "Save"
      page.should have_content("Name is required")
    end

    it "validates email is present" do
      fill_in "user_email", with: ""
      click_button "Save"
      page.should have_content("Email is required")
    end

    it "validates user password and confirmation match" do
      fill_in "user_password", with: "password"
      fill_in "user_password_confirmation", with: "password2"
      click_button "Save"
      page.should have_content(I18n.t("activerecord.errors.models.monologue/user.attributes.password.confirmation"))
    end

    it "doesn't change password if none is provided" do
      u = storage_session.repo.user.find_by_email(user.email)
      click_button "Save"
      storage_session.reset
      u.current.password_digest.should eq(u.password_digest)
    end
  end

  context "Logged in" do
    let!(:user_without_post) { FactoryGirl.build(:orm_user, session: storage_session) }
    let!(:user_with_post) { FactoryGirl.build(:orm_user_with_post, session: storage_session) }
    let(:user_without_post_model) { Monologue::User::ViewAdapter.new(user_without_post.current) }
    let(:user_with_post_model) { Monologue::User::ViewAdapter.new(user_with_post.current) }

    it "should be able to see the list of available users" do
      storage_session.commit

      visit admin_users_path
      page.should have_content(user_without_post.email)
      page.should have_content(user_with_post.email)
    end

    it "should be able to create a new user" do
      visit admin_users_path
      click_on I18n.t("monologue.admin.users.index.create")
      fill_in "user_name", with: "John"
      fill_in "user_email", with: "john@doe.com"
      fill_in "user_password", with: "password"
      fill_in "user_password_confirmation", with: "password"
      click_button I18n.t("monologue.admin.users.new.create")
      page.should have_content(I18n.t("monologue.admin.users.create.success"))
    end

    it "should not be able to delete user with posts" do
      storage_session.commit

      visit admin_users_path
      delete= I18n.t("monologue.admin.users.index.delete")
      page.should_not have_link(delete, href: admin_user_path(user_with_post_model))
      page.should_not have_link(delete, href: admin_user_path(user_model))
      page.should have_link(delete, href: admin_user_path(user_without_post_model))
    end
  end
end
