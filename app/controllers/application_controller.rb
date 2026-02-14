class ApplicationController < ActionController::Base
  layout false
  include Authentication
  include Pagy::Backend
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    redirect_to root_path
  end

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  helper_method :current_user_id
  helper_method :current_user

  private

  def current_user_id
    if authenticated?
      Current.user.id
    end
  end

  def current_user
    if authenticated?
      Current.user
    end
  end

  def record_not_found
    flash[:alert] = "Запрашиваемый ресурс не найден"
    redirect_to root_path
  end
end
