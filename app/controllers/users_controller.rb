    require_relative './application_controller'
    require_relative '../models/user.rb'

    class UsersController < ApplicationController

      def new
        # debugger
        # @user = User.new(name: "Maverick", age: 48)
        # @user.save
      end
    end
