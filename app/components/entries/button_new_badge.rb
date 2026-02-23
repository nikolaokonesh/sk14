class Components::Entries::ButtonNewBadge < Phlex::HTML
  register_value_helper :lucide_icon

  def view_template
    button(id: "new_message_badge",
      class: "hidden fixed bottom-18 right-4 chat chat-end z-50", # right-4 чтобы не прилипало к краю
      data: {
        action: "click->autoscroll#scrollToBottom",
        autoscroll_target: "badge"
      }) do
      div(class: "chat-bubble chat-bubble-secondary flex px-2 min-w-0 shadow-lg cursor-pointer") do
        span { lucide_icon("arrow-down", class: "size-5") }
        span(class: "ml-1 text-xs font-bold") { "новое" }
      end
    end
  end
end
