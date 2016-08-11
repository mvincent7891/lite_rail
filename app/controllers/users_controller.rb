    require_relative './application_controller'
    require_relative '../models/user.rb'

    class UsersController < ApplicationController
      def initialize
      end

      def new
        @user = User.new(name: "James", age: 20)
        @user.save
      end
    end
