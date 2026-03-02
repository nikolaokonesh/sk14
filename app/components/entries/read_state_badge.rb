class Components::Entries::ReadStateBadge < Phlex::HTML
  include Phlex::Rails::Helpers::DOMID

  def initialize(entry:, user:)
    @entry = entry
    @user = user
  end

  def view_template
    span(id: dom_id(@entry, :read_state_badge), class: "absolute top-2 right-2 z-10") do
      unread = @user.unread_comments_count_for(@entry)
      show_count = @user.show_unread_comments_count_for?(@entry)

      if unread.positive?
        text = show_count ? "Не прочитано * #{unread}" : "Не прочитано"
        span(class: "badge badge-warning badge-sm") { text }
      else
        span(class: "badge badge-success badge-sm") { "Прочитано" }
      end
    end
  end
end
