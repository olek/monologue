module Monologue
  class Admin::PostsController < Admin::BaseController
    respond_to :html
    cache_sweeper Monologue::PostsSweeper, only: [:create, :update, :destroy]
    before_filter :load_post, only: [:edit, :update]

    def index
      @posts = post_repo.find_all_for_admin_listing.map { |p| Post::ViewAdapter.new(p) }
    end

    def new
      @post = Post::ViewAdapter.new(post_repo.create)
    end

    ## Preview a post without saving.
    def preview
      # mockup our models for preview.
      @post = Post::ViewAdapter.new(post_repo.create)
      @post.assign_attributes(params[:post])
      @post.user_id = monologue_current_user.id
      @post.published_at = Time.zone.now

      # render it exactly as it would display when live.
      render "/monologue/posts/show", layout: Monologue.layout || "/layouts/monologue/application"
    end

    def create
      @post = Post::ViewAdapter.new(post_repo.create)
      @post.user_id = monologue_current_user.id
      if @post.update_attributes(params[:post])
        prepare_flash_and_redirect_to_edit()
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @post.update_attributes(params[:post])
        prepare_flash_and_redirect_to_edit()
      else
        render :edit
      end
    end

    def destroy
      post = post_repo.find_by_id(params[:id])
      post_repo.delete(post)
      redirect_to admin_posts_path, notice:  I18n.t("monologue.admin.posts.delete.removed")
    rescue ORMivore::StorageError
      redirect_to admin_posts_path, alert: I18n.t("monologue.admin.posts.delete.failed")
    end

  private
    def load_post
      @post = Post::ViewAdapter.new(post_repo.find_by_id(params[:id]))
    end

    def post_repo
      storage_session.repo.post
    end

    def prepare_flash_and_redirect_to_edit
      if @post.published_in_future? && ActionController::Base.perform_caching
        flash[:warning] = I18n.t("monologue.admin.posts.#{params[:action]}.saved_with_future_date_and_cache")
      else
        flash[:notice] =  I18n.t("monologue.admin.posts.#{params[:action]}.saved")
      end
      redirect_to edit_admin_post_path(@post.id)
    end
  end
end
