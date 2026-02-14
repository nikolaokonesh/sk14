class AuthVerificationController < ApplicationController
  allow_unauthenticated_access
  skip_before_action :verify_authenticity_token, if: -> { request.format.json? }

  def create
    user = User.find_by(email: session[:email])

    if user.present? && user.valid_auth_code?(params[:verification_code])
      access_token = user.access_tokens.create!
      cookies.permanent.encrypted[:access_token] = access_token.token
      session.delete(:email)        # Удаляет временную сессию хранения email
      start_new_session_for user    # Создает новую сессию авторизованному пользователю

      respond_to do |format|
        format.html { redirect_to user_name_present?(user), notice: "Вы вошли в систему" }
        format.json { render json: { token: access_token.token } }
      end
    else
      respond_to do |format|
        format.html do
          flash[:alert] = "Проверьте свой проверочный код и повторите попытку."
          redirect_to auth_verification_path
        end
        format.json do
          render json: { msg: "invalid-verification-code." }, status: :unauthorized
        end
      end
    end
  end

  def show
    @session = session[:email]
    if authenticated?
      redirect_to after_authentication_url
    elsif @session.nil?
      flash[:notice] = "Введите свой E-mail"
      redirect_to after_authentication_url
    else
      render Views::Auth::Verification.new(session: @session)
    end
  end

  private

  def user_name_present?(user) # Проверяет есть ли у пользователя имя, если нету то скидывает на добавление имени
    if user.name.present?
      after_authentication_url
    else
      flash[:notice] = "Введите своё Имя и Фамилию"
      user_name_index_path
    end
  end
end
