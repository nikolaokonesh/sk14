class AuthMailer < ApplicationMailer
  def auth_code(user, auth_code)
    @user = user
    @auth_code = auth_code

    render_email(
      Views::Auth::MailerCode,
      subject: @auth_code,
      to: @user.email,
      view_params: { auth_code: @auth_code }
    )
  end
end
