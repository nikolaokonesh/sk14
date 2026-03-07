class Components::AutoServices::Header < Components::Base
  def initialize(mode:)
    @mode = mode
  end

  def view_template
    div(class: "w-full sticky top-0 py-2 z-10 bg-base-300") do
      div(class: "flex justify-between items-center mx-4 gap-2") do
        div(class: "text-xl font-bold") { "Услуги авто" }

        div(class: "join") do
          a(href: auto_services_path(mode: "passenger"), class: "join-item btn btn-sm #{@mode == 'passenger' ? 'btn-primary' : 'btn-ghost'}") { "Услуги авто" }
          if authenticated?
            a(href: auto_services_path(mode: "services"), class: "join-item btn btn-sm #{@mode == 'services' ? 'btn-primary' : 'btn-ghost'}") { "Мои услуги" }
            a(href: new_auto_service_path, class: "join-item btn btn-sm btn-secondary") { "+" }
          end
        end
      end
    end
  end
end
