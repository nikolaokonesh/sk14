class Auth::VerificationController < ApplicationController
  allow_unauthenticated_access

  def show
    @contact = session[:contact]
    @contact_type = session[:contact_type]
    
    if authenticated?
      redirect_to after_sign_in_path_for(Current.user)
    elsif @contact.nil?
      flash[:notice] = "Введите номер телефона или email"
      redirect_to auth_sign_path
    else
      render :show
    end
  end

  def create
    contact = session[:contact]
    contact_type = session[:contact_type]
    
    # 🆕 Ищем пользователя по телефону или email
    user = if contact_type == "email"
      User.find_by(email: contact)
    else
      User.find_by(phone: contact)
    end

    if user.present? && user.valid_auth_code?(params[:verification_code])
      start_new_session_for(user)
      session.delete(:contact)
      session.delete(:contact_type)

      redirect_to after_sign_in_path_for(user), notice: "✅ Вы вошли в систему"
    else
      flash[:alert] = "Неверный код. Попробуйте ещё раз."
      redirect_to auth_verification_path
    end
  end

  private

  def after_sign_in_path_for(user)
    if user.name_present?
      root_path
    else
      flash[:notice] = "Представьтесь, пожалуйста"
      auth_name_path
    end
  end
end