class Monologue::Admin::UsersController < Monologue::Admin::BaseController

  before_filter :load_user, except: [:index, :new, :create]

  def edit

  end

  def new
    @user = Monologue::UserRecord.new
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
    if @user.destroy
      redirect_to admin_users_path, notice:  I18n.t("monologue.admin.users.delete.removed", user: @user.name)
    else
      redirect_to admin_users_path, alert: I18n.t("monologue.admin.users.delete.failed", user: @user.name)
   end
  end

  def create
    @user = Monologue::UserRecord.new(params[:user])
    if @user.save
      flash.notice = I18n.t("monologue.admin.users.create.success")
      redirect_to admin_users_path
    else
      render :new
    end
  end

  def index
    @users = Monologue::UserRecord.all
  end

  private
    def load_user
      @user = Monologue::UserRecord.find(params[:id])
    end

end
