class Auth::Mailer < ApplicationMailer
  default from: "no-reply@sk14.ru"  # 🆅 Укажи свой email отправителя
  
  def code(user, code)
    @user = user
    @code = code
    
    # 🆕 Определяем имя получателя
    recipient_name = user.name.familiar if user.name_present?
    
    mail(
      to: user.email,
      subject: "Код подтверждения для входа — #{@code}"
    )
  end
end