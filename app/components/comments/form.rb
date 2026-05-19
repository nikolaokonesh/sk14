# frozen_string_literal: true

class Components::Comments::Form < Components::Base
  def initialize(entry:)
    @entry = entry
  end

  def view_template
    div(id: dom_id(@entry, :comment_form), class: "mt-4 rounded-2xl bg-base-200/50 p-3") do
      form_with(model: [ @entry, Entry.new ], url: entry_comments_path(@entry), class: "space-y-2") do |f|
        plain f.rich_text_area :content,
                              placeholder: "Напишите комментарий в стиле чата…",
                              class: "lexxy-content"

        div(class: "flex items-center justify-between") do
          span(class: "text-xs opacity-60") { "Shift+Enter — новая строка" }
          plain f.submit "Отправить", class: "btn btn-primary btn-sm"
        end
      end
    end
  end
end
