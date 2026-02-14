class Components::Shared::Flash < Phlex::HTML
  include Phlex::Rails::Helpers::StripTags
  include Phlex::Rails::Helpers::Sanitize
  register_value_helper :flash

  def view_template
    div(id: "flash") do
      if flash.any?
        flash.each do |msg_type, message|
          div(data_controller: "notification",
              data_notification_delay_value: "5000",
              class: "transition transform duration-700 hidden fixed top-24 z-50 font-bold alert #{notice_class_for(msg_type)}",
              data_transition_enter_from: "opacity-0 translate-x-0",
              data_transition_enter_to: "opacity-100 translate-x-6",
              data_transition_leave_from: "opacity-100 translate-x-0",
              data_transition_leave_to: "opacity-0 translate-x-6") do
            p { sanitize(strip_tags(message)) }
          end
        end
      end
    end
  end

  private

  def notice_class_for(flash_type)
    {
      success: "alert-success",
      error: "alert-error",
      alert: "alert-warning",
      notice: "alert-info"
    }.stringify_keys[flash_type.to_s] || flash_type.to_s
  end
end
