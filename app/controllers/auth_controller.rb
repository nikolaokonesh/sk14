class AuthController < ApplicationController
  allow_unauthenticated_access only: %i[ show create ]
  skip_before_action :verify_authenticity_token, if: -> { request.format.json? }
  # rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to auth_url, alert: "Try again later." }

  def show
    if authenticated?
      flash[:notice] = "Вы уже вошли"
      redirect_to root_path
    else
      render Views::Auth::Sign.new(params: params[:email], session: session[:email])
    end
  end

  def create
    email = params[:email].downcase.strip
    user = User.find_or_create_by(email: email)

    AuthMailer.auth_code(user, user.auth_code).deliver_now
    session[:email] = email

    respond_to do |format|
      format.html { redirect_to auth_verification_path, notice: "Вам отправлен код подтверждения." }
      format.json { render json: { msg: "verification-email-sent" } }
    end
  end

  def destroy
    cookies.delete :access_token
    terminate_session

    respond_to do |format|
      format.html { redirect_to auth_path, notice: "Вы вышли из системы" }
      format.json { render json: { msg: "signed-out" } }
    end
  end
end
