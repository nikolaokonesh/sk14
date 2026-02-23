# frozen_string_literal: true

class Components::Pagination::NextPage < Phlex::HTML
  include Phlex::Rails::Helpers::TurboFrameTag
  register_value_helper :pagy_url_for

  def initialize(pagy:, frame_prefix: "entries-page")
    @pagy = pagy
    @frame_prefix = frame_prefix
  end

  def view_template
    turbo_frame_tag(
      "#{@frame_prefix}-#{@pagy.next}",
      loading: :lazy,
      src: pagy_url_for(@pagy, @pagy.next),
      target: "_top",
      refresh: :morph
      ) do
      render Components::Pagination::Skeleton.new
    end
  end
end
