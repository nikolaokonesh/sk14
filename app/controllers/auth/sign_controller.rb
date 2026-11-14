class Auth::SignController < ApplicationController
  allow_unauthenticated_access only: %i[ show create ]
  rate_limit to: 5, within: 1.minute, only: :create, 
             with: -> { redirect_to auth_sign_path, alert: "Слишком много попыток. Подождите 1 минуту." }

  def show
    if authenticated?
      flash[:notice] = "Вы уже вошли"
      redirect_to root_path
    else
      render :show
    end
  end

  def create
    if params[:honeypot].present?
      Rails.logger.warn "🤖 Bot blocked (honeypot) from IP: #{request.remote_ip}"
      redirect_to auth_sign_path, notice: "Код отправлен."
      return
    end

    contact = params[:contact].to_s.strip
    
    # 🆕 Определяем тип контакта
    if email?(contact)
      # Email
      email = normalize_email(contact)
      
      unless valid_email?(email)
        flash.now[:alert] = "Неверный формат email"
        render :show, status: :unprocessable_entity
        return
      end
      
      user = User.find_or_create_by(email: email)
      session[:contact] = email
      session[:contact_type] = "email"
      
    else
      # Телефон
      phone = normalize_phone(contact)
      
      unless valid_phone?(phone)
        flash.now[:alert] = "Неверный формат телефона. Используйте +7..., 7... или 8..."
        render :show, status: :unprocessable_entity
        return
      end
      
      # Rate limit по номеру
      cache_key = "sms_attempts_#{phone}"
      attempts = Rails.cache.increment(cache_key, expires_in: 10.minutes)
      
      if attempts > 3
        Rails.logger.warn "🚫 Rate limit exceeded for phone: #{phone}"
        redirect_to auth_sign_path, alert: "Слишком много запросов на этот номер. Подождите 10 минут."
        return
      end
      
      user = User.find_or_create_by(phone: phone)
      session[:contact] = phone
      session[:contact_type] = "phone"
    end
    
    # Отправляем код
    result = send_auth_code(user)
    
    if Rails.env.development?
      redirect_to auth_verification_path, 
                  notice: "📱 Код отправлен на #{session[:contact]}. В разработке код: #{result[:debug_code]}"
    else
      redirect_to auth_verification_path, 
                  notice: "📱 Код отправлен на #{session[:contact]}"
    end
  end

  def destroy
    terminate_session
    redirect_to auth_sign_path, notice: "Вы вышли из системы"
  end

  private
  
  # 🆕 Определение типа контакта
  def email?(contact)
    contact.include?('@')
  end
  
  def normalize_phone(phone)
    return "" unless phone.present?
    cleaned = phone.to_s.gsub(/\D/, '')
    
    if cleaned.start_with?('8') && cleaned.length >= 11
      "+7#{cleaned[1..-1]}"
    elsif cleaned.start_with?('7')
      "+#{cleaned}"
    else
      "+#{cleaned}"
    end
  end
  
  def normalize_email(email)
    email.to_s.downcase.strip
  end
  
  def valid_phone?(phone)
    phone.match?(/\A\+7\d{10,14}\z/)
  end
  
  def valid_email?(email)
    email.match?(URI::MailTo::EMAIL_REGEXP)
  end
  
  # 🆕 Отправка кода (SMS или Email)
  def send_auth_code(user)
    if user.email.present?
      # 🆕 Вызов через полный namespace
      Auth::Mailer.code(user, user.auth_code).deliver_now
      { success: true, debug_code: user.auth_code }
    else
      # Отправляем SMS (имитация)
      SmsSender.auth_code(user)
    end
  end
end