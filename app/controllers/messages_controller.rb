class MessagesController < ApplicationController
    def create
        @user = ::User.find_by( username: @@current_username)
        @message = @user.messages.create( body:message_params[:body], from_bot: false)
        sleep(1)
        redirect_to  controller:'chatrooms', action:'index'
    end

    def show
        @message
    end

    
    private
        def message_params
            params.require(:message).permit(:body)
        end
end
