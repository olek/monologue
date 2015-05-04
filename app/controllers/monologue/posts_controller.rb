module Monologue
  class PostsController < ApplicationController
    caches_page :index, :show, :feed , if: Proc.new { monologue_page_cache_enabled? }

    def index
      @page = params[:page].nil? ? 1 : params[:page]
      # @posts = Monologue::PostRecord.published.page(@page)
      @posts, @total_posts = post_repo.paginate_reader_listing(@page)
      @posts = @posts.map { |p| Post::ViewAdapter.new(p) }
    end

    def show
      @post = post_repo.find_by_url(params[:post_url])
      if monologue_current_user
        #@post = Monologue::PostRecord.default.where("url = :url", {url: params[:post_url]}).first
      else
        #@post = Monologue::PostRecord.published.where("url = :url", {url: params[:post_url]}).first
        @post = nil if @post && !@post.published
      end
      if @post
        @post = Post::ViewAdapter.new(@post)
      else
        not_found
      end
    end

    def feed
      #@posts = Monologue::PostRecord.published.limit(25)
      @posts = post_repo.find_all_for_feed_listing.map { |p| Post::ViewAdapter.new(p) }
    end

    private

    def post_repo
      storage_session.repo.post
    end
  end
end
