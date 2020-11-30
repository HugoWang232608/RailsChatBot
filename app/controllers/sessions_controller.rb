class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(username: user_params[:username], password:user_params[:password])
    if user
      @@current_username = user_params[:username]
      redirect_to :chatrooms_index
    else
      flash.now[:login_error] = "invalid username or password"
      render "new"
    end
  end

  private
    def user_params
      params.require(:session).permit(:username, :password)
    end
end
