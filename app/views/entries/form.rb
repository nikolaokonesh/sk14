# frozen_string_literal: true

class Views::Entries::Form < Views::Base
  def initialize(entry:)
    @entry = entry
  end

  def page_title = @entry.new_record? ? "Новый пост" : "Изменить пост"
  def layout = Layout

  def view_template
    turbo_frame_tag "entry_modal", refresh: "morph" do
      dialog(id: "modal_form", class: "modal modal-open modal-bottom", data: { controller: "close-modal" }) do
        div(class: "modal-box p-1 max-h-[75%] md:max-h-[90%] max-w-3xl pb-10") do
          h1(class: "text-4xl font-bold my-5 mx-2") { page_title }

          form_with(model: @entry, class: "contents") do |form|
            div(class: "my-5") do
              form.fields_for :entryable do |fields|
                if @entry.entryable.errors[:content].any?
                  p(class: "text-red-500 mx-2") { @entry.entryable.errors[:content].join(", ") }
                else
                  fields.label :content, "Содержание", class: "mx-2"
                end
                fields.lexxy_rich_text_area :content, placeholder: "Добавить описание", require: true, rows: 5, class: "lexxy-content pb-4 shadow-sm rounded-md mt-2"
              end
            end
            form.hidden_field :entryable_type, value: "Post"

            div(class: "inline mx-2") {
              form.submit "Сохранить", class: "btn btn-primary", data: { turbo_submits_with: "Обновление..." }
            }
          end
          button(class: "btn", data: { action: "click->close-modal#close" }) { "Отмена" }
        end
      end
    end
  end
end
