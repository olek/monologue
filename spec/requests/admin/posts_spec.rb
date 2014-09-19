# encoding: UTF-8
require 'spec_helper'
describe "posts" do
  let(:storage_session) { ORMivore::Session.new(Monologue::Repos, Monologue::Associations) }

  context "logged in user" do
    before(:each) do
      log_in
    end
    
    it "can access post's admin" do
      visit admin_posts_path
      page.should have_content "Add a monologue"
    end
    
    it "can create new post" do
      visit new_admin_post_path
      page.should have_content "New monologue"
      fill_in "Title", with:  "my title"
      fill_in "Content", with:  "C'est l'histoire d'un gars comprends tu...and finally it has some french accents àèùöûç...meh!"
      fill_in "Published at", with:  DateTime.now
      click_button "Save"
      page.should have_content "Monologue created"
    end

    it "can edit a post and then save the post" do
      post = FactoryGirl.build(:orm_post, title: "my title", session: storage_session)
      storage_session.commit_and_reset

      visit admin_posts_path
      click_on "my title"
      page.should have_content "Edit \""
      fill_in "Title", with:  "This is a new title"
      fill_in "Content", with:  "New content here..."
      fill_in "Published at", with:  DateTime.now
      click_button "Save"

      page.should have_content "Monologue saved"
      post.current.content.should ==  "New content here..."
      post.current.title.should ==  "This is a new title"
    end
    
    it "will output error messages if error(s) there is" do
      visit new_admin_post_path
      page.should have_content "New monologue"
      click_button "Save"
      page.should have_content "Title is required"
      page.should have_content "Content is required"
      page.should have_content "'Published at' is required"
    end

    it "can create a new post with tags removing the empty spaces" do
      visit new_admin_post_path
      fill_in "Title", with:  "title"
      fill_in "Content", with:  "content"
      fill_in "Published at", with:  DateTime.now
      fill_in "Tags",with: "  rails, ruby,    one great tag"
      click_button "Save"
      page.should have_field :tag_list ,with: "rails, ruby, one great tag"
    end

    it "can update the tags of an edited post" do
      FactoryGirl.build(:orm_post, title: "my title", session: storage_session)
      storage_session.commit
      visit admin_posts_path
      click_on "my title"
      fill_in "Tags",with: "ruby, spree"
      click_button "Save"
      page.should have_field :tag_list ,with: "ruby, spree"
    end
  end
  
  context "NOT logged in user" do
    it "can NOT access post's admin" do
      visit admin_posts_path
      page.should have_content "You must first log in"
    end

    it "can NOT create new post" do
      visit new_admin_post_path
      page.should have_content "You must first log in"
    end
    
    it "can NOT edit posts" do
      post = FactoryGirl.build(:orm_post, session: storage_session)
      storage_session.commit
      post_model = Monologue::Post::ViewAdapter.new(post.current)

      visit edit_admin_post_path(post_model)
      page.should have_content "You must first log in"
    end
  end  
end
