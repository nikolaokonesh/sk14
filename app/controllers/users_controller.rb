class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[ show ]
  before_action :set_user, only: %i[ show edit update ]

  def show
    @entries = @user.entries
                    .active
                    .includes(user: { avatar: { avatar_attachment: :blob } }, entryable: :entry)
                    .where(entryable_type: "Post")
                    .recent
    @pagy, @entries = pagy_countless(@entries)
    render Views::Users::Show.new(
      user: @user,
      entries: @entries,
      pagy: @pagy,
      params: params[:page]
    )
  end

  def edit
    @user = Current.user
    render Views::Users::Edit.new(user: @user)
  end

  def update
    if @user == Current.user
      @user = Current.user
      if @user.update(user_params)
        flash[:success] = "Профиль успешно обновлен!"
        redirect_to user_path(@user)
      else
        render Views::Users::Edit.new(user: @user), status: :unprocessable_entity
      end
    else
      flash[:error] = "Не Ваш профиль."
      redirect_to root_path
      redirect_to user_path(@user)
    end
  end

  private

  def set_user
    @user = User.friendly.find(params[:id])
  end

  def user_params
    params.expect(user: [ :name, :slug ])
  end
end
