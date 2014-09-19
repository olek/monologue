require 'spec_helper'
describe "tag category" do
  let(:storage_session) { ORMivore::Session.new(Monologue::Repos, Monologue::Associations) }

  after do
    clear_cache
  end

  describe "Viewing the tag category" do

    before(:each) do
      FactoryGirl.build(:orm_post_with_tags, session: storage_session)
      post = FactoryGirl.build(:orm_post, title: "Future post", published_at: DateTime.new(3000), session: storage_session)
      post.session.association(post.current, :tags).add(
        FactoryGirl.build(:orm_tag, name: 'Rails', session: post.session)
      )
      storage_session.commit
    end

    it "should only display the frequency of tags used by published post" do
      visit "/monologue"
      page.should have_content("Rails (1)")
    end

  end
end
