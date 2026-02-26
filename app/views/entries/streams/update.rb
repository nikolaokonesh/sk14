# frozen_string_literal: true

class Views::Entries::Streams::Update < Phlex::HTML
  include Phlex::Rails::Helpers::TurboStream
  include Phlex::Rails::Helpers::DOMID

  def initialize(
    entry:,
    message: nil
  )
    @entry = entry
    @message = message
  end

  def view_template
    turbo_stream.replace dom_id(@entry) do
      render Components::Entries::Card.new(entry: @entry, highlight: true)
    end

    # Обновляет контент в entrys/show.rb
    turbo_stream.update "content_#{dom_id(@entry)}" do
      render Components::Entries::Content.new(entry: @entry)
    end

    if @message
      turbo_stream.update :flash do
        render Components::Shared::Flash.new
      end
    end
  end
end
