class Views::Notifications::Page < Components::Base
  def initialize(notifications:, pagy:)
    @notifications = notifications
    @pagy = pagy
  end

  def view_template
    turbo_frame_tag "notifications-page-#{@pagy.page}", refresh: :morph do
      div(class: "space-y-3") do
        @notifications.each do |notification|
          render Components::Notifications::Item.new(notification: notification)
        end
      end

      if @pagy.next.present?
        turbo_frame_tag("notifications-page-#{@pagy.next}", loading: :lazy, src: pagy_url_for(@pagy, @pagy.next), target: "_top", refresh: :morph) do
          render Components::Pagination::Skeleton.new
        end
      end
    end
  end
end
