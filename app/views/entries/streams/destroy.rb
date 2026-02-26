# frozen_string_literal: true

class Views::Entries::Streams::Destroy < Phlex::HTML
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
    turbo_stream.update :trash_size do
      @entry.user.trash_size
    end

    turbo_stream.update :entries_size do
      @entry.user.entries_size
    end

    turbo_stream.remove dom_id(@entry)

    if @message
      turbo_stream.update :flash do
        render Components::Shared::Flash.new
      end
    end
  end
end
