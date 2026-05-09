# frozen_string_literal: true

class Components::Advertisements::Card < Components::Base
  def initialize(entryable:, show_actions: false, compact: false)
    # Если передали Entry (оболочку), берем из неё entryable (саму рекламу)
    # Если уже передали Advertisement — оставляем как есть
    @ad = entryable.is_a?(Entry) ? entryable.entryable : entryable

    @show_actions = show_actions
    @compact = compact
  end

  def view_template
    # Используем @ad, у которого точно есть метод theme_gradient
    article(class: "rounded-3xl p-[1px] bg-gradient-to-r #{@ad.theme_gradient} shadow-xl") do
      a(href: advertisement_path(@ad.entry), class: "block") do
        render_body
      end

      render_actions if show_actions?
    end
  end

  private

  def render_body
    # Здесь тоже используем @ad для доступа к связанному entry
    entry = @ad.entry
    variant = entry.preview_variant

    div(class: [ "bg-base-100 rounded-3xl overflow-hidden relative", (@compact ? "p-3 min-h-24" : "p-4") ]) do
      if variant
        img(
          src: url_for(variant),
          class: "absolute inset-0 w-full h-full object-cover opacity-35",
          alt: "",
          loading: "lazy",
          decoding: "async"
        )
        div(class: "absolute inset-0 bg-base-100/35")
      end

      div(class: "relative z-10") do
        # Берем данные через @ad
        p(class: "text-xs opacity-60 mb-2") { "В топе · #{@ad.user.username}" }
        h2(class: [ "font-extrabold line-clamp-4", (@compact ? "text-base mb-1" : "text-xl mb-2") ]) do
          entry.title
        end
      end
    end
  end

  def render_actions
    div(class: "px-4 pb-4 pt-3") do
      a(href: edit_advertisement_path(@ad.entry), class: "btn btn-xs") { "Редактировать" }
    end
  end

  def show_actions?
    # can? обычно работает с объектом из БД, передаем @ad.entry
    @show_actions && can?(:update, @ad.entry)
  end
end
