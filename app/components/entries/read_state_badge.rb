class Components::Entries::ReadStateBadge < Phlex::HTML
  include Phlex::Rails::Helpers::DOMID

  def initialize(entry:, user:)
    @entry = entry
    @user = user
  end

  def view_template
    span(id: dom_id(@entry, :read_state_badge), class: "absolute top-2 right-2 z-10 flex gap-1") do
      render_post_state_badge
      render_unread_comments_badge
    end
  end

  def render_post_state_badge
    if @user.post_read_for?(@entry)
      span(class: "badge badge-success badge-sm") { "Прочитано" }
    else
      span(class: "badge badge-warning badge-sm") { "Не прочитано" }
    end
  end

  def render_unread_comments_badge
    unread = @user.unread_comments_count_for(@entry)
    return unless unread.positive?
    return unless @user.show_unread_comments_count_for?(@entry)

    span(class: "badge badge-error badge-sm") { "+#{unread} комм." }
  end
end
