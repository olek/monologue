module Monologue
  class Admin::PostsController < Monologue::Admin::BaseController
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
      @post = Post::Entity.new(post_params)

      @post = post_repo.persist(@post)

      persist_tag_list(params[:post][:tag_list])

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

      @post = @post.repo.persist(@post)

      persist_tag_list(params[:post][:tag_list])

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
      @post = post_repo.find_by_id(params[:id])
    end

    def persist_tag_list(tag_list)
      if tag_list
        tag_names = tag_list.split(",").map(&:strip).reject(&:blank?)
        found_tags = tag_repo.find_all_by_names(tag_names)
        created_tags = (tag_names - found_tags.map(&:name)).map { |tn|
          tag_repo.persist(Tag::Entity.new(name: tn))
        }

        already_associated_tags =
          tagging_repo.find_all_by_post_id(@post.id).map { |tagging|
            matching_tag = found_tags.detect { |ft| tagging.tag_id == ft.id }
            tagging_repo.delete(tagging) unless matching_tag
            matching_tag
          }.compact

        tags_to_associate = found_tags - already_associated_tags + created_tags

        tags_to_associate.each do |tag|
          tagging_repo.persist(Tagging::Entity.new(post_id: @post.id, tag_id: tag.id))
        end
      end
    end

    def post_repo
      repos[Post::Entity]
    end

    def tag_repo
      post_repo.family[Tag::Entity]
    end

    def tagging_repo
      post_repo.family[Tagging::Entity]
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
end
