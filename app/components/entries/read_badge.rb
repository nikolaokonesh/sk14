class Components::Entries::ReadBadge < Phlex::HTML
  include Phlex::Rails::Helpers::DOMID
  include Phlex::Rails::Helpers::TurboFrameTag
  register_value_helper :lucide_icon

  def initialize(entry:, user:)
    @entry = entry
    @user = user
  end

  def view_template
    turbo_frame_tag "read" do
      span(id: dom_id(@entry, :read_badge), class: "flex items-center pr-1") do
        render_post_state_badge
      end
    end
  end

  def render_post_state_badge
    span(class: [ "ml-3", (@user.post_read_for?(@entry) ? "text-info" : "text-gray-500 opacity-30") ]) { lucide_icon("check-check", size: 18) }
  end
end
