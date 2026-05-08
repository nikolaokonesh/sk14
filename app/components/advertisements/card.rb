# frozen_string_literal: true

class Components::Advertisements::Card < Components::Base
  def initialize(entryable:, show_actions: false, compact: false)
    @entryable = entryable
    @show_actions = show_actions
    @compact = compact
  end

  def view_template
    # Используем градиент из модели рекламы
    article(class: "rounded-3xl p-[1px] bg-gradient-to-r #{@entryable.theme_gradient} shadow-xl") do
      a(href: advertisement_path(@entryable.entry), class: "block") do
        render_body
      end

      render_actions if show_actions?
    end
  end

  private

  def render_body
    # Используем новый метод из Entry::Content, который возвращает уже настроенный вариант
    variant = @entryable.entry.preview_variant(width: 200, height: 200)

    div(class: [ "bg-base-100 rounded-3xl overflow-hidden relative", (@compact ? "p-3 min-h-24" : "p-4") ]) do
      if variant
        img(
          src: url_for(variant),
          class: "absolute inset-0 w-full h-full object-cover opacity-35",
          alt: "",
          loading: "lazy",  # Ленивая загрузка для экономии трафика
          decoding: "async" # Асинхронное декодирование для плавности скролла
        )
        # Полупрозрачный слой поверх картинки для читаемости текста
        div(class: "absolute inset-0 bg-base-100/35")
      end

      # Контентная часть (заголовок и автор)
      div(class: "relative z-10") do
        p(class: "text-xs opacity-60 mb-2") { "В топе · #{@entryable.user.username}" }
        h2(class: [ "font-extrabold line-clamp-4", (@compact ? "text-base mb-1" : "text-xl mb-2") ]) do
          @entryable.entry.title
        end
      end
    end
  end

  def render_actions
    div(class: "px-4 pb-4 pt-3") do
      a(href: edit_advertisement_path(@entryable.entry), class: "btn btn-xs") { "Редактировать" }
    end
  end

  def show_actions?
    @show_actions && can?(:update, @entryable.entry)
  end
end
