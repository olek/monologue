require 'spec_helper'

describe Monologue::Admin::PostsController do
  let(:storage_session) { ORMivore::Session.new(Monologue::Repos, Monologue::Associations) }
  let(:user) { FactoryGirl.build(:orm_user, session: storage_session) }

  before do
    @routes = Monologue::Engine.routes
  end

  describe 'PUT #update' do
    let(:post) { FactoryGirl.build(:orm_post, session: storage_session) } #, user: user.current) }
    let(:new_content) { 'This is the new content, for real!' }
    let(:new_title) { 'nothing to do, I find it awesome!' }

    context :valid do
      before do
        user; post # create them
        storage_session.commit
        sign_in_as user.current

        put :update,
          id: post.current.identity,
          post: {
            content: new_content,
            title: new_title
          }
        storage_session.commit_and_reset
        @post = post.current
      end

      it { expect(@post.content).to eq new_content }
      it { expect(@post.title).to eq new_title }
    end

    # context :invalid do
    #   before do
    #   end
    # end
  end
end
