# frozen_string_literal: true

class Components::Comments::Message < Components::Base
  def initialize(entry:, root_entry:)
    @entry = entry
    @root_entry = root_entry
  end

  def view_template
    article(id: dom_id(@entry), class: "rounded-2xl bg-base-200/70 p-3 shadow-sm") do
      div(class: "flex items-center gap-2 text-sm") do
        span(class: "font-bold") { @entry.user.username(:full) }
        span(class: "opacity-50") { helpers.time_ago_in_words(@entry.created_at) + " назад" }

        if authenticated? && can?(:destroy, @entry)
          a(href: entry_comment_path(@root_entry, @entry),
            class: "ml-auto text-error opacity-70 hover:opacity-100",
            data: { turbo_method: :delete, turbo_confirm: "Удалить комментарий?" }) { "Удалить" }
        end
      end

      div(class: "lexxy-show prose prose-stone max-w-none mt-2 break-words") { raw @entry.content.to_s }
    end
  end
end
