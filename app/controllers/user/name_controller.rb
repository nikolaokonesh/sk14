class User::NameController < ApplicationController
  before_action :set_user, only: %i[ index update ]
  def index
    if @user.name.blank?
      render Views::Users::Name::Edit.new(user: @user)
    else
      flash[:success] = "Вы ввели свое имя как #{@user.name.full}!"
      redirect_to user_path(@user)
    end
  end

  def update
    if @user.name.blank?
      if @user.update(user_params)
        flash[:success] = "Привет, #{@user.name.full}!"
        redirect_to root_path
      else
        render Views::Users::Name::Edit.new(user: @user), status: :unprocessable_entity
      end
    else
      flash[:success] = "Вы ввели свое имя как #{@user.name.full}!"
      redirect_to edit_user_path(@user)
    end
  end

  private

  def set_user
    @user = Current.user
  end

  def user_params
    params.expect(user: [ :name ])
  end
end
