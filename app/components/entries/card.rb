# frozen_string_literal: true

class Components::Entries::Card < Phlex::HTML
  include Phlex::Rails::Helpers::Sanitize
  include Phlex::Rails::Helpers::StripTags
  include Phlex::Rails::Helpers::DOMID
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::Truncate
  register_value_helper :lucide_icon
  register_value_helper :current_user_id

  # def cache_store
  #   Rails.cache
  # end

  def initialize(entry:, highlight: false, is_first: nil, is_last: nil)
    @entry = entry
    @highlight = highlight
    @is_first = is_first.nil? ? @entry.first_in_group? : is_first
    @is_last = is_last.nil? ? @entry.last_in_group? : is_last
  end

  def view_template
    @avatar = @entry.user.avatar.updated_at.to_s if @entry.user.avatar.present?
    @username = @entry.user.username
    div(id: dom_id(@entry),
        data: { controller: "auth-visibility #{(@highlight ? "highlight" : nil)}",
                auth_visibility_author_id_value: @entry.user_id },
        class: [ "chat chat-start items-end", ("-mt-3" unless @is_last) ]) do
      div(class: "chat-image avatar sticky bottom-16 self-end") do
        div(class: "w-10 rounded-full") do
          if @is_first
            render Components::Users::Avatar.new(user: @entry.user)
          end
        end
      end
      div(class: "chat-header flex items-center") do
        span(class: "pr-3") { sanitize(strip_tags(@entry.user.username)) }
        time(class: "opacity-50") { render Components::Shared::TimeAgoInWords.new(entry: @entry) }
        time do
          case @entry.entryable
          when Post
            render Components::Posts::Card.new(post: @entry.entryable) do |card|
              card.nav
            end
          end
        end
      end
      div(class: [ "chat-bubble max-w-[99%]", ("before:hidden" unless @is_first), (@highlight ? "animate-shimmer-bottom" : nil) ]) do
        case @entry.entryable
        when Post
          render Components::Posts::Card.new(post: @entry.entryable) do |card|
            card.content
          end
        when Comment
          render Components::Comments::Card.new(entry: @entry) do |card|
            card.card_comment_for_root_page
          end
        end
      end
      div(class: "chat-footer opacity-50") { @entry.tags_list }
    end
  end
end
