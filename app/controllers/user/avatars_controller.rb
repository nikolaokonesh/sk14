class User::AvatarsController < ApplicationController
  before_action :set_user_avatar, only: %i[ show edit update destroy ]

  # GET /user/avatars/1 or /user/avatars/1.json
  def show
    if @user_avatar.user == Current.user
      render Views::Users::Avatars::Form.new(user_avatar: @user_avatar)
    else
      redirect_to root_path
    end
  end

  # GET /user/avatars/new
  def new
    @user_avatar = User::Avatar.new
    render Views::Users::Avatars::Form.new(user_avatar: @user_avatar)
  end

  # GET /user/avatars/1/edit
  def edit
    render Views::Users::Avatars::Form.new(user_avatar: @user_avatar)
  end

  # POST /user/avatars or /user/avatars.json
  def create
    @user_avatar = Current.user.build_avatar(user_avatar_params)
    if @user_avatar.save
      flash[:success] = "Аватар успешно создан."
      redirect_to @user_avatar
    else
      render Views::Users::Avatars::Form.new(user_avatar: @user_avatar), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /user/avatars/1 or /user/avatars/1.json
  def update
    if @user_avatar.user == Current.user
      if @user_avatar.update(user_avatar_params)
        flash[:notice] = "Аватар успешно обновлён."
        redirect_to @user_avatar
      else
        render Views::Users::Avatars::Form.new(user_avatar: @user_avatar), status: :unprocessable_entity
      end
    else
      flash[:error] = "Это не Ваш аватар"
      redirect_to @user_avatar
    end
  end

  # DELETE /user/avatars/1 or /user/avatars/1.json
  def destroy
    if @user_avatar.user == Current.user
      @user_avatar.destroy!
      flash[:alert] = "Аватар удален."
      redirect_to new_user_avatar_path, status: :see_other
    else
      flash[:error] = "Это не Ваш аватар"
      redirect_to @user_avatar
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_avatar
      @user_avatar = User::Avatar.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def user_avatar_params
      params.expect(user_avatar: [ :avatar ])
    end
end
