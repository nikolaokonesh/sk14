class Auth::NameController < ApplicationController
  before_action :require_authentication
  before_action :set_user

  def show
    if @user.name_present?
      flash[:notice] = "Вы уже представились: #{@user.name.full}"
      redirect_to root_path
    else
      render :show
    end
  end

  def update
    if @user.update(user_params)
      flash[:notice] = "Приятно познакомиться, #{@user.name.full}!"
      redirect_to root_path
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.expect(user: [ :name ])
  end
end