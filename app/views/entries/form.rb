# frozen_string_literal: true

class Views::Entries::Form < Views::Base
  def initialize(entry:)
    @entry = entry
  end

  def page_title = @entry.new_record? ? "Новый пост" : "Изменить пост"

  def view_template
    div(class: "py-4") do
      h1(class: "text-3xl font-black mb-4 px-2 tracking-tight") { page_title }

      form_with(model: @entry, class: "space-y-6") do |form|
        div(class: "form-control") do
          if @entry.errors[:content].any?
            p(class: "text-error text-sm font-bold mb-2") { @entry.errors[:content].join(", ") }
          else
            form.label :content, "Содержание", class: "label font-bold opacity-70 mb-2"
          end

          div(class: "relative") do
            # Радужная подложка (glow)
            render Components::Shared::BgGradient.new
            plain form.rich_text_area :content, placeholder: "Добавить описание", require: true, class: "lexxy-content min-h-[300px]"
          end
        end

        div(class: "form-control") do
          form.fields_for :entryable do |fields|
            label(class: "label cursor-pointer justify-start gap-4 p-2 bg-base-300/30 rounded-xl") do
              plain fields.check_box :no_comments, checked: @entry.entryable.no_comments?, class: "checkbox checkbox-primary"
              span(class: "label-text font-medium") { "Без комментариев" }
            end
          end
        end

        form.hidden_field :entryable_type, value: "Post"

        div(class: "flex items-center gap-3 pt-4") do
          plain form.submit "Сохранить", class: "btn btn-primary shadow-lg shadow-primary/20 flex-1 md:flex-none"
          a(href: @entry.new_record? ? root_path : entry_path(@entry), class: "btn btn-ghost flex-1 md:flex-none") { "Отмена" }
        end
      end
    end
  end
end
