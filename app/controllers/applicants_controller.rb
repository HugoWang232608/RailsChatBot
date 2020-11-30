class ApplicantsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.create(user_params)
    if @user.save
      redirect_to :sessions_new
    else
      render "new"
    end
  end

  private
    def user_params
      params.require(:user).permit(:username, :password)
    end
end
