# frozen_string_literal: true

class Views::Entries::Streams::Create < Phlex::HTML
  include Phlex::Rails::Helpers::TurboStream

  def initialize(entry:, message: nil)
    @entry = entry
    @message = message
  end

  def view_template
    turbo_stream.prepend "entries" do
      render Components::Entries::Card.new(entry: @entry, highlight: true)
    end

    if @message
      turbo_stream.update :flash do
        div(id: "flashing_#{@entry.id}", data: { turbo_permanent: true }) { render Components::Shared::Flash.new }
      end
    end
  end
end
