# frozen_string_literal: true

class Views::Comments::Streams::Create < Phlex::HTML
  include Phlex::Rails::Helpers::TurboStream
  include Phlex::Rails::Helpers::DOMID

  def initialize(entry:)
    @entry = entry
  end

  def view_template
    prev_entry = @entry.root.descendants.where("id < ?", @entry.id).order(id: :desc).first

    is_same_author = prev_entry && prev_entry.user_id == @entry.user_id

    if is_same_author
      starter = @entry.group_starter
      target_id = "bubbles_container_#{dom_id(starter)}"

      turbo_stream.append(target_id) do
        render_bubble(@entry, is_first: false, is_last: true, class_target: "last-comment", highlight: true)
      end

      turbo_stream.replace(dom_id(prev_entry)) do
        render_bubble(prev_entry, is_first: (prev_entry.id == starter.id), is_last: false, class_target: "")
      end
    else
      turbo_stream.append(dom_id(@entry.root, :comments_list)) do
        render_group_container(@entry)
      end
    end

    turbo_stream.update("comment_error")
  end

  private

  def render_group_container(entry)
    group_wrapper_id = "group_#{dom_id(entry)}"
    bubbles_id = "bubbles_container_#{dom_id(entry)}"
    div(id: group_wrapper_id, data: { controller: "chat-visibility", chat_visibility_target: "chat", auth_visibility_author_id_value: entry.user_id },
        class: "chat chat-start comment-card group items-end m-1") do
      div(class: "chat-image avatar self-stretch flex items-end", data: { chat_visibility_target: "avatar" }) do
        div(class: "w-10 rounded-full sticky bottom-2 transition-all") do
          render Components::Users::Avatar.new(user: entry.user)
        end
      end
      div(
        id: bubbles_id,
        class: "flex flex-col -ml-2 -mb-4"
      ) do
        render_bubble(entry, is_first: true, is_last: true, class_target: "last-comment", highlight: true)
      end
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
