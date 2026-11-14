class SmsSender
  def self.auth_code(user)
    code = user.auth_code
    
    Rails.logger.info "=" * 60
    Rails.logger.info "📱 ИМИТАЦИЯ ОТПРАВКИ SMS"
    Rails.logger.info "Номер: #{user.phone}"
    Rails.logger.info "Код: #{code}"
    Rails.logger.info "=" * 60
    
    if Rails.env.development?
      { success: true, debug_code: code }
    else
      # В production здесь будет реальный SMS-шлюз
      { success: true }
    end
  end
end