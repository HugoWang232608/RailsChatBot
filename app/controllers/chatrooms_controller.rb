class ChatroomsController < ApplicationController
    def index
        @username = @@current_username
        @user = User.find_by(username: @@current_username)
        
    end
end
