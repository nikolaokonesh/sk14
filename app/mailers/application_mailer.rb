class ApplicationMailer < ActionMailer::Base
  default from: "sk14.ru"
  layout false

  def render_email(view_class, subject:, to:, view_params: {})
    mail({ subject:, to:, content_type: "multipart/alternative" }) do |format|
      format.html {
        render Components::Mailers::Html.new {
          render view_class.const_get(:Html).new(**view_params)
        }
      }
      format.text {
        render Components::Mailers::Text.new {
          render view_class.const_get(:Text).new(**view_params)
        }
      }
    end
  end
end
