# frozen_string_literal: true

class Views::Advertisements::Index < Views::Base
  def initialize(top_advertisements:, advertisement:)
    @top_advertisements = top_advertisements
    @advertisement = advertisement
  end

  def view_template
    section(class: "py-4 px-2 space-y-5") do
      h1(class: "text-3xl font-black tracking-tight") { "Реклама чего угодно" }
      p(class: "opacity-70 text-sm") { "Публикуйте свои идеи, события, услуги и проекты. Новые объявления автоматически поднимаются в топ." }

      if @advertisement
        render_form
      else
        a(href: auth_sign_path, class: "btn btn-primary btn-block rounded-2xl") { "Войти, чтобы добавить рекламу" }
      end

      div(class: "space-y-4") do
        @top_advertisements.each do |advertisement|
          article(class: "rounded-3xl p-[1px] bg-gradient-to-r #{advertisement.theme_gradient} shadow-xl") do
            div(class: "bg-base-100 rounded-3xl p-4") do
              p(class: "text-xs opacity-60 mb-2") { "В топе · #{advertisement.user.name}" }
              h2(class: "text-lg font-extrabold mb-2") { advertisement.title }
              p(class: "opacity-80 text-sm mb-4") { advertisement.description }
              a(href: advertisement.cta_url, target: "_blank", rel: "noopener", class: "btn btn-sm btn-primary rounded-xl") { advertisement.cta_text }

              if can?(:update, advertisement)
                div(class: "mt-3 flex flex-wrap gap-2") do
                  form_with(model: advertisement, method: :patch, class: "inline") do |form|
                    plain form.hidden_field :active, value: (!advertisement.active?).to_s
                    plain form.hidden_field :top_placement, value: advertisement.top_placement
                    plain form.hidden_field :paid_until, value: advertisement.paid_until
                    plain form.submit(advertisement.active? ? "Скрыть" : "Показать", class: "btn btn-xs rounded-xl")
                  end

                  if can?(:destroy, advertisement)
                    form_with(model: advertisement, method: :delete, class: "inline") do |form|
                      plain form.submit "Удалить", class: "btn btn-xs btn-error rounded-xl", data: { turbo_confirm: "Удалить рекламу?" }
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  private

  def render_form
    form_with(model: @advertisement, class: "bg-base-200 rounded-3xl p-4 space-y-4 shadow") do |form|
      div do
        form.label :title, "Заголовок", class: "label font-bold"
        plain form.text_field :title, class: "input input-bordered w-full rounded-2xl", placeholder: "Например: Ищу художника для коллаборации"
      end

      div do
        form.label :description, "Описание", class: "label font-bold"
        plain form.text_area :description, rows: 4, class: "textarea textarea-bordered w-full rounded-2xl", placeholder: "Что предлагаете и почему это стоит внимания"
      end

      div(class: "grid grid-cols-1 sm:grid-cols-2 gap-3") do
        div do
          form.label :cta_text, "Текст кнопки", class: "label font-bold"
          plain form.text_field :cta_text, class: "input input-bordered w-full rounded-2xl", placeholder: "Открыть"
        end
        div do
          form.label :cta_url, "Ссылка", class: "label font-bold"
          plain form.url_field :cta_url, class: "input input-bordered w-full rounded-2xl", placeholder: "https://..."
        end
      end

      div do
        form.label :theme, "Тема карточки", class: "label font-bold"
        plain form.select :theme, Advertisement::THEMES.keys.map { |theme| [theme.titleize, theme] }, {}, class: "select select-bordered w-full rounded-2xl"
      end

      plain form.submit "Поднять рекламу в топ", class: "btn btn-primary btn-block h-12 rounded-2xl"
    end
  end
end
