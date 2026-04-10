module CancanAndRecord
  extend ActiveSupport::Concern

  included do
    rescue_from CanCan::AccessDenied do |exception|
      flash[:error] = exception.message
      redirect_to root_path
    end

    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  end

  private

  def record_not_found
    flash[:alert] = "Запрашиваемый ресурс не найден"
    redirect_to root_path
  end
end
