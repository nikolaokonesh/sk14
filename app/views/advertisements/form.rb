# frozen_string_literal: true

class Views::Advertisements::Form < Views::Base
  def initialize(entry:)
    @entry = entry
  end

  def page_title
    @entry.new_record? ? "Новая реклама" : "Изменить рекламу"
  end

  def view_template
    section(class: "py-4 px-2") do
      h1(class: "text-3xl font-black tracking-tight mb-4") { page_title }

      form_with(model: @entry, url: @entry.new_record? ? advertisements_path : advertisement_path(@entry), class: "bg-base-200 rounded-3xl p-4 space-y-4 shadow") do |form|
        div do
          form.label :content, "Текст рекламы", class: "label font-bold"
          plain form.rich_text_area :content, class: "lexxy-content", placeholder: "Добавьте текст, фото и документы"
        end

        form.fields_for :entryable do |fields|
          div do
            fields.label :theme, "Тема карточки", class: "label font-bold"
            plain fields.select :theme, Advertisement::THEMES.keys.map { |theme| [ theme.titleize, theme ] }, {}, class: "select select-bordered w-full rounded-2xl"
          end

          div(class: "form-control bg-info/20 rounded-md p-2") do
            label(class: "label cursor-pointer justify-start gap-4 py-2 bg-base-300/30 rounded-xl px-4") do
              plain raw lucide_icon("messages-square", class: "size-4")
              span(class: "label-text font-medium") { "Без комментариев" }
              plain fields.check_box :no_comments, checked: @entry.entryable.no_comments?, class: "checkbox checkbox-primary"
            end
          end
        end

        form.hidden_field :entryable_type, value: "Advertisement"

        div(class: "flex gap-3") do
          plain form.submit "Сохранить", class: "btn btn-primary flex-1"
          a(href: advertisements_path, class: "btn btn-ghost") { "Отмена" }
        end
      end
    end
  end
end
