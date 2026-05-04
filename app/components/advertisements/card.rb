# frozen_string_literal: true

class Components::Advertisements::Card < Components::Base
  def initialize(entryable:, show_actions: false, compact: false)
    @entryable = entryable
    @show_actions = show_actions
    @compact = compact
  end

  def view_template
    article(class: "rounded-3xl p-[1px] bg-gradient-to-r #{@entryable.theme_gradient} shadow-xl") do
      a(href: advertisement_path(@entryable.entry), class: "block") do
        render_body
      end

      render_actions if show_actions?
    end
  end

  private

  def render_body
    image = @entryable.first_image_embed

    div(class: [ "bg-base-100 rounded-3xl overflow-hidden relative", (@compact ? "p-3 min-h-24" : "p-4") ]) do
      if image
        img(src: url_for(image), class: "absolute inset-0 w-full h-full object-cover opacity-35", alt: "")
        div(class: "absolute inset-0 bg-base-100/35")
      end

      div(class: "relative z-10") do
        p(class: "text-xs opacity-60 mb-2") { "В топе · #{@entryable.user.username}" }
        h2(class: [ "font-extrabold line-clamp-4", (@compact ? "text-base mb-1" : "text-xl mb-2") ]) { @entryable.entry.title }
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
