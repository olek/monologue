# encoding: UTF-8
require 'spec_helper'
describe "feed" do
  let(:storage_session) { ORMivore::Session.new(Monologue::Repos, Monologue::Associations) }

  before(:each) do
    FactoryGirl.build(:orm_post, url: "url/to/post", session: storage_session)
    storage_session.commit
  end
  
  # test to prevent regression for issue #72
  it "should contain full" do
    visit feed_path
    page.should have_content "/monologue/url/to/post"
  end
end
