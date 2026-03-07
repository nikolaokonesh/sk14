class AutoServices::ScheduleRefreshJob < ApplicationJob
  queue_as :default

  def perform
    changed = false

    AutoService.where(activity_state: AutoService::STATE_SCHEDULE).find_each do |service|
      available = service.available_now?

      if available && !service.available_snapshot?
        service.update_columns(available_snapshot: true, activated_at: Time.current, updated_at: Time.current)
        changed = true
      elsif !available && service.available_snapshot?
        service.update_columns(available_snapshot: false, updated_at: Time.current)
        changed = true
      end
    end

    Turbo::StreamsChannel.broadcast_refresh_to(:auto_services) if changed
  end
end
