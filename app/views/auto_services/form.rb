# frozen_string_literal: true

class Views::AutoServices::Form < Views::Base
  def initialize(entry:)
    @entry = entry
    @service = @entry.entryable || AutoService.new
  end

  def page_title = @entry.new_record? ? "Новая авто услуга" : "Редактирование услуги"
  def layout = Layout

  def view_template
    div(class: "p-4") do
      h1(class: "text-3xl font-bold mb-4") { page_title }

      form_with(model: @entry, url: @entry.new_record? ? auto_services_path : auto_service_path(@entry), class: "space-y-4") do |form|
        form.hidden_field :entryable_type, value: Entry::AUTO_SERVICE_TYPE

        form.fields_for :entryable do |fields|
          div do
            fields.label :service_kinds, "Виды услуг", class: "font-semibold"
            div(class: "grid md:grid-cols-2 gap-2 mt-2") do
              AutoService::SERVICE_KINDS.each do |label, value|
                div(class: "flex items-center gap-2") do
                  checked = Array(@service.service_kinds).include?(value)
                  fields.check_box :service_kinds,
                                   { multiple: true, checked: checked, include_hidden: false, class: "checkbox checkbox-sm" },
                                   value,
                                   nil
                  fields.label "service_kinds_#{value}", label
                end
              end
            end
            field_error(:service_kinds)
          end

          field_row(fields, :car_brand, "Марка авто")
          field_row(fields, :plate_number, "Гос. номер")
          field_row(fields, :phone, "Телефон")
          field_row(fields, :city_trip_price, "Цена поездки по городу")

          div do
            fields.label :schedule_mode, "Режим графика", class: "label"
            fields.select :schedule_mode, AutoService::SCHEDULE_MODES, {}, class: [ "select select-bordered w-full", { "select-error": service_errors(:schedule_mode).any? } ]
            field_error(:schedule_mode)
          end

          div do
            fields.label :work_days_array, "Дни недели", class: "font-semibold"
            div(class: "grid grid-cols-2 md:grid-cols-4 gap-2 mt-2") do
              selected_days = @service.work_days_array
              AutoService::DAY_OPTIONS.each do |label, value|
                div(class: "flex items-center gap-2") do
                  fields.check_box :work_days_array,
                                   { multiple: true, checked: selected_days.include?(value), include_hidden: false, class: "checkbox checkbox-sm" },
                                   value,
                                   nil
                  fields.label "work_days_array_#{value}", label
                end
              end
            end
            field_error(:work_days_array)
          end

          div(class: "grid md:grid-cols-2 gap-2") do
            time_row(fields, :work_from, "Начало работы")
            time_row(fields, :work_to, "Конец работы")
          end

          div do
            fields.label :notes, "Комментарий", class: "label"
            fields.text_area :notes, class: [ "textarea textarea-bordered w-full", { "textarea-error": service_errors(:notes).any? } ], rows: 3
            field_error(:notes)
          end
        end

        div(class: "flex gap-2") do
          form.submit "Сохранить", class: "btn btn-primary"
          a(href: auto_services_path(mode: "services"), class: "btn") { "Отмена" }
        end
      end
    end
  end

  private

  def field_row(fields, attr, label)
    div do
      fields.label attr, label, class: "label"
      fields.text_field attr, class: [ "input input-bordered w-full", { "input-error": service_errors(attr).any? } ]
      field_error(attr)
    end
  end

  def time_row(fields, attr, label)
    div do
      fields.label attr, label, class: "label"
      fields.time_field attr, class: [ "input input-bordered w-full", { "input-error": service_errors(attr).any? } ]
    end
  end

  def field_error(attr)
    return unless service_errors(attr).any?

    p(class: "text-red-500 text-sm mt-1") { service_errors(attr).join(", ") }
  end

  def service_errors(attr)
    return [] unless @service.respond_to?(:errors)

    Array(@service.errors[attr])
  end
end
