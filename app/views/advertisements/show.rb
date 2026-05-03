# frozen_string_literal: true

class Views::Advertisements::Show < Views::Base
  def initialize(entry:)
    @entry = entry
  end

  def view_template
    article(class: "py-4 px-2") do
      div(class: "rounded-3xl p-[1px] bg-gradient-to-r #{@entry.entryable.theme_gradient} shadow-xl") do
        div(class: "bg-base-100 rounded-3xl overflow-hidden") do
          div(class: "p-5") do
            p(class: "text-xs opacity-60") { "Рекламная публикация · #{@entry.user.name}" }
            div(class: "lexxy-show text-lg leading-relaxed prose prose-stone max-w-none") { @entry.content.to_s }

            if can?(:update, @entry)
              div(class: "mt-6 flex flex-wrap gap-2") do
                a(href: edit_advertisement_path(@entry), class: "btn btn-sm btn-primary") { "Редактировать" }

                form_with(model: @entry, method: :delete, class: "inline") do |form|
                  plain form.submit "Удалить", class: "btn btn-sm btn-error", data: { turbo_confirm: "Удалить рекламу?" }
                end
              end
            end
          end
        end
      end
    end
  end
end
