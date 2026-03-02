# To deliver this notification:
#
# Comments::NewReplyNotifier.with(record: @post, message: "New post").deliver(User.all)

class Comments::NewReplyNotifier < ApplicationNotifier
  deliver_by :database

  def message
    params[:title].presence || "Новый ответ на ваш комментарий"
  end

  def body
    params[:body].presence || "Вам ответили в комментариях"
  end

  def url
    return unless params[:root_entry_id].present?

    Rails.application.routes.url_helpers.entry_path(params[:root_entry_id])
  end

  # Add your delivery methods
  #
  # deliver_by :email do |config|
  #   config.mailer = "UserMailer"
  #   config.method = "new_post"
  # end
  #
  # bulk_deliver_by :slack do |config|
  #   config.url = -> { Rails.application.credentials.slack_webhook_url }
  # end
  #
  # deliver_by :custom do |config|
  #   config.class = "MyDeliveryMethod"
  # end

  # Add required params
  #
  # required_param :message

  # Compute recipients without having to pass them in
  #
  # recipients do
  #   params[:record].thread.all_authors
  # end
end
