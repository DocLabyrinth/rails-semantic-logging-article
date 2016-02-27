class UsersController < ApplicationController
  def index
    @user = User.first
    Rails.logger.info("Loaded user", {:user_id => @user.id, :username => @user.username})
    sleep_time = rand(0.1..3).round(4)
    sleep sleep_time
    Rails.logger.info("Annoying random sleep", {:duration => sleep_time})
  end
end
