class Components::AutoServices::Card < Components::Base
  def initialize(entry:)
    @entry = entry
    @service = entry.entryable
  end

  def view_template
    div(class: [ "space-y-0.5", (@service.fresh_for_passenger? ? "animate-shimmer-bottom" : nil) ]) do
      p(class: "font-semibold") { @service.service_kind_names.join(", ") }
      p { "Марка: #{@service.car_brand}" }
      p { "Гос. номер: #{@service.plate_number}" }
      p { "Телефон: #{@service.phone}" }
      p { "По городу: #{@service.city_trip_price.present? ? "#{@service.city_trip_price} ₽" : "по договоренности"}" }
      p { "График: #{@service.schedule_label}" }
      p { "Статус: #{@service.available_now? ? "В работе" : "Не активен"}" }
      if @entry.trash?
        p { "Услуга УДАЛЕНА, скоро будет удален навсегда, вы можете востановить." }
      end
      p(class: "opacity-80") { @service.notes } if @service.notes.present?

      if authenticated? && @entry.user_id == Current.user.id && request.params[:mode] == "services"
        div(class: "flex flex-col") do
          div(class: "flex flex-wrap gap-2 py-2") do
            unless @entry.trash?
              a(href: edit_auto_service_path(@entry, mode: "services"),
                class: "btn btn-xs btn-outline btn-info"
              ) { lucide_icon("pencil", size: 14) }
            end

            if @entry.trash?
              a(href: restore_auto_service_path(@entry, mode: "services"),
                class: "btn btn-xs btn-success",
                data: { turbo_method: :patch, turbo_confirm: "Восстановить услугу?" }
              ) { "Восстановить" }
            else
              a(href: auto_service_path(@entry, mode: "services"),
                class: "btn btn-xs btn-outline btn-error",
                data: { turbo_method: :delete, turbo_confirm: "Удалить услугу в корзину?" }
              ) { lucide_icon("trash", size: 14) }
            end
          end

          div(class: "flex flex-wrap gap-2 py-2 min-w-[350px]") do
            unless @entry.trash?
              a(href: set_activity_auto_service_path(@entry, activity_state: AutoService::STATE_MANUAL, mode: "services"),
                class: "btn btn-xs #{@service.manual? ? 'btn-success' : 'btn-ghost'}",
                data: { turbo_method: :patch }
              ) { "Активен" }

              a(
                href: set_activity_auto_service_path(@entry, activity_state: AutoService::STATE_SCHEDULE, mode: "services"),
                class: "btn btn-xs #{@service.schedule? ? 'btn-success' : 'btn-ghost'}",
                data: { turbo_method: :patch }
              ) { "Активность по графику" }

              a(
                href: set_activity_auto_service_path(@entry, activity_state: AutoService::STATE_OFF, mode: "services"),
                class: "btn btn-xs #{@service.off? ? 'btn-error' : 'btn-ghost'}",
                data: { turbo_method: :patch }
              ) { "Выключен" }
            end
          end
        end
      end
    end
  end
end
