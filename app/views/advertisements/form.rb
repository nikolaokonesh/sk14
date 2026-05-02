# frozen_string_literal: true

class Views::Advertisements::Form < Views::Base
  def initialize(advertisement:)
    @advertisement = advertisement
  end

  def page_title
    @advertisement.new_record? ? "Новая реклама" : "Изменить рекламу"
  end

  def view_template
    section(class: "py-4 px-2") do
      h1(class: "text-3xl font-black tracking-tight mb-4") { page_title }

      form_with(model: @advertisement, class: "bg-base-200 rounded-3xl p-4 space-y-4 shadow") do |form|
        div do
          form.label :content, "Текст рекламы", class: "label font-bold"
          plain form.rich_text_area :content, class: "lexxy-content", placeholder: "Добавьте текст, фото и документы"
        end

        div do
          form.label :theme, "Тема карточки", class: "label font-bold"
          plain form.select :theme, Advertisement::THEMES.keys.map { |theme| [theme.titleize, theme] }, {}, class: "select select-bordered w-full rounded-2xl"
        end

        div(class: "flex gap-3") do
          plain form.submit "Сохранить", class: "btn btn-primary flex-1"
          a(href: advertisements_path, class: "btn btn-ghost") { "Отмена" }
        end
      end
    end
  end
end
