require 'spec_helper'
describe "tags" do
  let(:storage_session) { ORMivore::Session.new(Monologue::Repos, Monologue::Associations) }

  after do
    clear_cache
  end

  describe "Viewing the list of posts with tags" do
    before(:each) do
      FactoryGirl.build(:orm_post_with_tags, title: "post X", session: storage_session)
      storage_session.commit
    end

    it "should display the tags for the posts as a link" do
      visit "/monologue"
      page.should have_link("Rails")
      page.should have_link("a great tag")
    end
  end

  describe "filtering by a given tag" do
    before(:each) do
      FactoryGirl.build(:orm_post_with_tags, title: "post X", session: storage_session)
      FactoryGirl.build(:orm_post_with_tags, title: "post Z", session: storage_session)
      storage_session.commit
    end

    it "should only display posts with the given tag" do
      visit "/monologue"
      page.should have_content("post Z")
      click_on "Rails"
      find(".content").should have_content("post X")
      find(".content").should_not have_content("post Z")
    end

    it "should not display posts with tags with future publication date" do
      post = FactoryGirl.build(:orm_post, title: "we need to reach 88 miles per hour", published_at: DateTime.new(3000), session: storage_session)
      post.session.association(post, :tags).add(
        FactoryGirl.build(:orm_tag, name: 'rails', session: post.session),
      )
      storage_session.commit

      visit "/monologue"
      click_on "Rails"
      page.should have_content("post X")
      page.should_not have_content("we need to reach 88 miles per hour")
    end
  end
end
