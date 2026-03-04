class Components::Entries::ReadStateBadge < Phlex::HTML
  include Phlex::Rails::Helpers::DOMID
  register_value_helper :lucide_icon

  def initialize(entry:, user:)
    @entry = entry
    @user = user
  end

  def view_template
    span(id: dom_id(@entry, :read_state_badge), class: "flex items-center pr-1") do
      render_unread_comments_badge
      render_post_state_badge
    end
  end

  def render_post_state_badge
    span(class: [ "ml-3", (@user.post_read_for?(@entry) ? "text-info" : "text-gray-500 opacity-30") ]) { lucide_icon("check-check") }
  end

  def render_unread_comments_badge
    unread = @user.unread_comments_count_for(@entry)
    return unless unread.positive?
    return unless @user.show_unread_comments_count_for?(@entry)

    span(class: "text-error text-sm") do
      "+#{unread}"
    end
  end
end
