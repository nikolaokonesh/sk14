# frozen_string_literal: true

class Components::Comments::Error < Phlex::HTML
  def initialize(
    entry:
  )
    @comment = entry.entryable
  end

  def view_template
    if @comment.errors[:content].any?
      div(data_controller: "notification",
          data_notification_delay_value: "5000",
          class: "absolute -mt-6 bg-base-300 text-red-500 text-xs py-1.5 px-2 transition transform duration-700",
          data_transition_enter_from: "opacity-0",
          data_transition_enter_to: "opacity-100",
          data_transition_leave_from: "opacity-100",
          data_transition_leave_to: "opacity-0") do
        p { @comment.errors[:content].join(", ") }
      end
    end
  end
end
