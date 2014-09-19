require 'spec_helper'
describe "tag cloud" do
  let(:storage_session) { ORMivore::Session.new(Monologue::Repos, Monologue::Associations) }

  after do
    clear_cache
  end

  describe "Viewing the tag cloud" do

    before(:each) do
      FactoryGirl.build(:orm_post_with_tags, session: storage_session)
      post = FactoryGirl.build(:orm_post, title: "Future post", published_at: DateTime.new(3000), session: storage_session)
      post.session.association(post.current, :tags).add(
        FactoryGirl.build(:orm_tag, name: 'Rails', session: post.session),
        FactoryGirl.build(:orm_tag, name: 'another tag', session: post.session)
      )
      storage_session.commit
    end

    it "should not display tags that are referenced by posts in the future" do
      visit "/monologue"
      page.should_not have_content("another tag")
    end

    it "should display tags that are referenced by published posts" do
      visit "/monologue"
      page.should have_content("Rails")
    end

  end
end
