class Monologue::TagsController < Monologue::ApplicationController
  caches_page :show , if: Proc.new { monologue_page_cache_enabled? }
  def show
    tag = retrieve_tag
    if tag
      @tag = Monologue::Tag::ViewAdapter.new(tag)
      @page = nil
      @posts = @tag.posts_with_tag
    else
      redirect_to :root ,notice: "No post found with label \"#{params[:tag]}\""
    end
  end

  private

  def retrieve_tag
    tag_repo.find_by_name(params[:tag])
  end

  def tag_repo
    storage_session.repo.tag
  end
end
