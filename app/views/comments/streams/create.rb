# frozen_string_literal: true

class Views::Comments::Streams::Create < Phlex::HTML
  include Phlex::Rails::Helpers::TurboStream
  include Phlex::Rails::Helpers::DOMID

  def initialize(entry:)
    @entry = entry
  end

  def view_template
    prev_entry = Entry.active
                      .where(root_id: @entry.root_id)
                      .where(entryable_type: "Comment")
                      .where.not(id: @entry.id)
                      .order(created_at: :asc)
                      .last

    is_same_author = prev_entry && prev_entry.user_id == @entry.user_id

    if is_same_author
      target_id = "group_bubbles_entry_#{prev_entry.group_anchor_id}"
      turbo_stream.append(target_id) do
        render_bubble(@entry, is_first: false, is_last: true, class_target: "last-entry", highlight: true)
      end

      turbo_stream.replace(dom_id(prev_entry)) do
        render_bubble(prev_entry, is_first: (prev_entry.id == prev_entry.group_anchor_id), is_last: false, class_target: "")
      end
    else
      turbo_stream.append dom_id(@entry.root, :comments_list) do
        render_group_container(@entry)
      end
    end

    turbo_stream.update("comment_error")
  end

  private

  def render_group_container(entry)
    group_wrapper_id = entry.group_anchor_id
    bubbles_id = "group_bubbles_entry_#{group_wrapper_id}"
    render Components::Entries::Group.new(
      user: entry.user,
      bubbles_id: bubbles_id,
      wrapper_class: "chat chat-start comment-card group items-end m-1",
      wrapper_data: { controller: "chat-visibility", chat_visibility_target: "chat", auth_visibility_author_id_value: entry.user_id },
      avatar_data: { chat_visibility_target: "avatar" },
      bubbles_class: "flex flex-col -ml-2 -mb-4",
      avatar_sticky_class: "sticky bottom-2"
    ) do
      render_bubble(entry, is_first: true, is_last: true, class_target: "last-entry", highlight: true)
    end
  end

  def render_bubble(entry, is_first:, is_last:, class_target: "", highlight: false)
    render Components::Comments::Card.new(
      entry: entry,
      is_first: is_first,
      is_last: is_last,
      highlight: highlight,
      class_target: class_target
    ) do |card|
      card.card_comment
    end
  end
end
