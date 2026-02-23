# frozen_string_literal: true

class Views::Entries::Streams::Create < Phlex::HTML
  include Phlex::Rails::Helpers::TurboStream
  include Phlex::Rails::Helpers::DOMID

  def initialize(entry:, message: nil)
    @entry = entry
    @message = message
  end

  def view_template
    prev_entry = Entry.active
                      .where(entryable_type: "Post")
                      .where.not(id: @entry.id)
                      .order(created_at: :asc)
                      .last

    is_same_author = prev_entry && prev_entry.user_id == @entry.user_id

    if is_same_author
      target_id = "group_bubbles_entry_#{prev_entry.group_anchor_id}"
      puts "<=============================================================================#{prev_entry.id}"
      turbo_stream.append(prev_entry) do
        render Components::Entries::Card.new(
          entry: @entry,
          highlight: true,
          is_first: false,
          is_last: true,
          show_avatar: false,
          class_target: "last-comment"
        )
      end

      turbo_stream.replace(dom_id(prev_entry)) do
        render Components::Entries::Card.new(
          entry: prev_entry,
          is_first: (prev_entry.id == prev_entry.group_anchor_id),
          is_last: false,
          show_avatar: false
        )
      end
    else
      turbo_stream.append("entries") do
        render_group_container(@entry)
      end
    end

    if @message
      turbo_stream.update :flash do
        div(id: "flashing_#{@entry.id}", data: { turbo_permanent: true }) { render Components::Shared::Flash.new }
      end
    end
  end

  private

  def render_group_container(entry)
    group_wrapper_id = entry.group_anchor_id
    bubbles_id = "group_bubbles_entry_#{group_wrapper_id}"
    render Components::Entries::Group.new(user: entry.user_id, bubbles_id: bubbles_id) do
      render Components::Entries::Card.new(
        entry: entry,
        highlight: true,
        is_first: true,
        is_last: true,
        show_avatar: false
      )
    end
  end
end
