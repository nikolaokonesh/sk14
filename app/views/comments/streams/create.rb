# frozen_string_literal: true

class Views::Comments::Streams::Create < Phlex::HTML
  include Phlex::Rails::Helpers::TurboStream
  include Phlex::Rails::Helpers::DOMID

  def initialize(entry:, previous_comment:)
    @entry = entry
    @previous_comment = previous_comment
  end

  def view_template
    turbo_stream.append dom_id(@entry.root, :comments_list) do
      render Components::Comments::Card.new(entry: @entry, is_last_in_group: true, highlight: true) { |card| card.card_comment }
    end

    if @previous_comment && @previous_comment.user_id == @entry.user_id
      turbo_stream.replace "entry_#{@previous_comment.id}" do
        render Components::Comments::Card.new(entry: @previous_comment, is_last_in_group: false) { |card| card.card_comment }
      end
    end

    turbo_stream.update("comment_error")
  end
end
