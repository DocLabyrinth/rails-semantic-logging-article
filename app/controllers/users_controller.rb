class UsersController < ApplicationController
  def index
    @user = User.first
  end
end
