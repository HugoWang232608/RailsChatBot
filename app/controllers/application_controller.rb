require "railschatbot"

class ApplicationController < ActionController::Base
    @@current_username = "default"
    def initialize

        @lita = Lita::Robot.new
        #@lita.register_adapter(:railschatbot)
        @lita.config.robot.adapter = :railschatbot

        botuser   = Lita::User.create(id: 1, name: "user")
        source = Lita::Source.new(user: botuser, room: "room")
        msg    = Lita::Message.new(@lita, "lita double 3", source)
        @lita.receive(msg)
    end
end
