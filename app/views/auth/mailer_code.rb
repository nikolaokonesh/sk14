class Views::Auth::MailerCode < Components::Base
  def initialize(auth_code:)
    @auth_code = auth_code
  end

  class Html < self
    def view_template
      h1 { "Добро пожаловать!" }
      p do
        plain " Введите этот код в течение 5 минут, чтобы войти: "
        b { @auth_code }
      end
      p do
        "Если вы не запрашивали этот код, вы можете спокойно проигнорировать это письмо. Кто-то другой мог ввести ваш адрес электронной почты по ошибке."
      end
    end
  end

  class Text < self
    def view_template
      plain " Введите этот код в течение 5 минут, чтобы войти: #{@auth_code}"
      plain "Если вы не запрашивали этот код, вы можете спокойно проигнорировать это письмо. Кто-то другой мог ввести ваш адрес электронной почты по ошибке."
    end
  end
end
