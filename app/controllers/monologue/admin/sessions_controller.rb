module Monologue
  class Admin::SessionsController < Admin::BaseController
    skip_before_filter :authenticate_user!
    
    def new
    end

    def create
      user = storage_session.repo.user.find_by_email(params[:email])
      user = User::ViewAdapter.new(user) if user
      if user && user.authenticate(params[:password])
        session[:monologue_user_id] = user.id
        redirect_to admin_url, notice: t("monologue.admin.sessions.messages.logged_in")
      else
        flash.now.alert = t("monologue.admin.sessions.messages.invalid")
        render "new"
      end
    end

    def destroy
      session[:monologue_user_id] = nil
      redirect_to admin_url, notice: t("monologue.admin.sessions.messages.logged_out")
    end
  end
end
