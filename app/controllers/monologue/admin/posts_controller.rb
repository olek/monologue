module Monologue
  class Admin::PostsController < Monologue::Admin::BaseController
    respond_to :html
    cache_sweeper Monologue::PostsSweeper, only: [:create, :update, :destroy]
    before_filter :load_post, only: [:edit, :update]

    def index
      @posts = Monologue::PostRecord.default
    end

    def new
      @post = Monologue::PostRecord.new
    end

    ## Preview a post without saving.
    def preview
      # mockup our models for preview.
      @post = Monologue::PostRecord.new(params[:post])
      @post.user_id = monologue_current_user.id
      @post.published_at = Time.zone.now

      # render it exactly as it would display when live.
      render "/monologue/posts/show", layout: Monologue.layout || "/layouts/monologue/application"
    end

    def create
      @post = Post::ViewAdapter.new(post_repo)
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
      post = Monologue::PostRecord.find(params[:id])
      if post.destroy
        redirect_to admin_posts_path, notice:  I18n.t("monologue.admin.posts.delete.removed")
      else
        redirect_to admin_posts_path, alert: I18n.t("monologue.admin.posts.delete.failed")
      end
    end

  private
    def load_post
      #@post = Monologue::PostRecord.find(params[:id])
      @post = Post::ViewAdapter.new(post_repo, post_repo.find_by_id(params[:id]))
    end

    def post_repo
      repos[Post::Entity]
    end

    def prepare_flash_and_redirect_to_edit
      if @post.entity.questions.published_in_future? && ActionController::Base.perform_caching
        flash[:warning] = I18n.t("monologue.admin.posts.#{params[:action]}.saved_with_future_date_and_cache")
      else
        flash[:notice] =  I18n.t("monologue.admin.posts.#{params[:action]}.saved")
      end
      redirect_to edit_admin_post_path(@post.id)
    end
  end
end
