class Views::AutoServices::Streams::SetActivity < Phlex::HTML
  include Phlex::Rails::Helpers::TurboStream
  include Phlex::Rails::Helpers::DOMID

  def initialize(entry:)
    @entry = entry
  end

  def view_template
    turbo_stream.update dom_id(@entry) do
      render Components::Entries::Card.new(entry: @entry, show_avatar: false, is_first: false, is_last: false)
    end
  end
end
