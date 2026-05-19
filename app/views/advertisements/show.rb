# frozen_string_literal: true

class Views::Advertisements::Show < Views::Base
  def initialize(entry:)
    @entry = entry
  end

  def view_template
    turbo_stream_from(@entry)

    article(class: "py-4 px-2") do
      # Кэшируем всё тело объявления. Если контент или тема не менялись,
      # Rails даже не заглянет в ActionText и Blobs.
      cache @entry do
        div(class: "rounded-3xl p-[1px] bg-gradient-to-r #{@entry.entryable.theme_gradient} shadow-xl") do
          div(class: "bg-base-100 rounded-3xl overflow-hidden") do
            div(class: "p-5") do
              p(class: "text-xs opacity-60") { "Рекламная публикация · #{@entry.user.name}" }

              # Выводим контент
              div(class: "lexxy-show text-lg leading-relaxed prose prose-stone max-w-none") do
                raw @entry.content.to_s
              end

              render_actions if can?(:update, @entry)
            end
          end
        end
      end

      render Components::Comments::Thread.new(entry: @entry)

    end
  end

  private

  def render_actions
    div(class: "mt-6 flex flex-wrap gap-2") do
      a(href: edit_advertisement_path(@entry), class: "btn btn-sm btn-primary") { "Редактировать" }

      # Форму лучше вынести за пределы кэша, если в ней есть CSRF-токены,
      # но для простоты оставим внутри, Rails сам обновит токен.
      form_with(model: @entry, method: :delete, class: "inline") do |form|
        plain form.submit "Удалить", class: "btn btn-sm btn-error", data: { turbo_confirm: "Удалить рекламу?" }
      end


    end
  end
end
