module Monologue
  class Admin::UsersController < Admin::BaseController

    before_filter :load_user, except: [:index, :new, :create]

    def edit
    end

    def new
      @user = User::ViewAdapter.new(user_repo.create)
    end

    def update
      if @user.update_attributes(params[:user])
        flash.notice = "User modified"
        redirect_to admin_users_path
      else
        render :edit
      end
    end

    def destroy
      user = user_repo.find_by_id(params[:id])
      user_repo.delete(user)
      redirect_to admin_users_path, notice:  I18n.t("monologue.admin.users.delete.removed", user: @user.name)
    rescue ORMivore::StorageError
      redirect_to admin_users_path, alert: I18n.t("monologue.admin.users.delete.failed", user: @user.name)
    end

    def create
      @user = User::ViewAdapter.new(user_repo.create)
      if @user.update_attributes(params[:user])
        flash.notice = I18n.t("monologue.admin.users.create.success")
        redirect_to admin_users_path
      else
        render :new
      end
    end

    def index
      @users = user_repo.find_all.map { |p| User::ViewAdapter.new(p) }
    end

    private

    def load_user
      @user = User::ViewAdapter.new(user_repo.find_by_id(params[:id]))
    end

    def user_repo
      storage_session.repo.user
    end
  end
end
