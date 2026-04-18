# frozen_string_literal: true

class Components::Entries::Card < Components::Base
  register_value_helper :current_user

  def initialize(entry: entry)
    @entry = entry
  end

  def view_template
    li(class: "list-row gap-0 hover:bg-base-200 active:bg-base-200 duration-100 p-2") do
      a(href: entry_path(@entry), class: "absolute inset-0 z-10", aria_label: "Читать далее")
      div(class: "flex items-end") do
        span(class: "mr-2") { @entry.user.username }
        span(class: "text-xs") { render Components::Shared::CreatedAt.new(entry: @entry) }
        span do
          if show_read_state_badge?
            render Components::Entries::ReadBadge.new(entry: @entry, user: Current.user)
          end
        end
      end
      p(class: "list-col-wrap") do
        cache(@entry) do
          plain truncate strip_tags(@entry.content.to_s).strip, length: 100
        end
      end
    end
  end

  private

  def show_read_state_badge?
    return false unless current_user
    return false unless @entry.user != current_user
    return false unless @entry.entryable_type == "Post"
    true
  end
end
