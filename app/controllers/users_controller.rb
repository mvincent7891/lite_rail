require_relative './application_controller'
require_relative '../models/user.rb'
require 'byebug'

class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(
    name: params["user"]["name"],
    age: params["user"]["age"])
    if @user.save
      flash.now[:notices] = "Successfully created user."
      redirect_to("/users")
    else
      flash.now[:errors] = "Unable to create user."
      render :new
    end

  end

  def index
    @users = User.all
  end

end
