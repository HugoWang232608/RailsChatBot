class MessagesController < ApplicationController
    #def new
    #    @message = Message.new
    #end

    def create
        @user = User.find_by( username: @@current_username)
        @message = @user.messages.create(message_params)
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
