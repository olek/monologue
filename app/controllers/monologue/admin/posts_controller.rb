class Monologue::Admin::PostsController < Monologue::Admin::BaseController
  respond_to :html
  cache_sweeper Monologue::PostsSweeper, only: [:create, :update, :destroy]
  #before_filter :load_post, only: [:edit, :update]
  before_filter :load_post, only: [:edit]
  before_filter :load_post_entity, only: [:update]
  
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
  
  def create_old
    @post = Monologue::PostRecord.new(params[:post])
    @post.user_id = monologue_current_user.id
    if @post.save
      prepare_flash_and_redirect_to_edit()
    else
      render :new
    end
  end

  def create
    post_params = params[:post].reject { |k| k == 'tag_list' } # temp, figure out how to handle tags
    post_params.merge!(user_id: monologue_current_user.id)
    # TODO missing step with form object and validations on it
    @post = Monologue::Post::Entity.new(post_params)

    @post = repos[:post].persist(@post)

    prepare_flash_and_redirect_to_edit()
  rescue ORMivore::StorageError
    raise
    # we do not have validations yet to fail
    # render :new
  end

  def edit
  end

  def update_old
    if @post.update_attributes(params[:post])
      prepare_flash_and_redirect_to_edit()
    else
      render :edit
    end
  end

  def update
    post_params = params[:post].reject { |k| k == 'tag_list' } # temp, figure out how to handle tags
    # TODO missing step with form object and validations on it
    @post = @post.apply(post_params)

    @post = repos[:post].persist(@post)

    prepare_flash_and_redirect_to_edit()
  rescue ORMivore::StorageError
    raise
    # we do not have validations yet to fail
    # render :edit
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
    @post = Monologue::PostRecord.find(params[:id])
  end

  def load_post_entity
    @post = repos[:post].find_by_id(params[:id])
  end

  def prepare_flash_and_redirect_to_edit
    if @post.questions.published_in_future? && ActionController::Base.perform_caching
      flash[:warning] = I18n.t("monologue.admin.posts.#{params[:action]}.saved_with_future_date_and_cache")
    else
      flash[:notice] =  I18n.t("monologue.admin.posts.#{params[:action]}.saved")
    end
    redirect_to edit_admin_post_path(@post.id)
  end
end
