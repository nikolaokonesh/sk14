# frozen_string_literal: true

class Components::Entries::Card < Components::Base
  def initialize(entry:, user:)
    @entry = entry
    @user = user
  end

  def view_template
    li(class: "list-row text-lg gap-0 hover:bg-base-200 active:bg-base-200 duration-100 p-2") do
      a(href: entry_path(@entry), class: "absolute inset-0 z-10", aria_label: "Читать далее")
      div(class: "flex items-center gap-2") do
        span { @entry.user.username }
        span(class: "text-xs pt-1") { render Components::Shared::CreatedAt.new(entry: @entry) }
        span { render(Components::Entries::ReadBadge.new(entry: @entry, user: @user)) if show_read_state_badge? }
      end
      p(class: "list-col-wrap") do
        plain truncate strip_tags(@entry.content.to_plain_text).strip, length: 100
      end
    end
  end

  private

  def show_read_state_badge?
    @user && @entry.user_id != @user.id && @entry.post?
  end
end
