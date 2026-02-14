class Components::Menu::Header < Components::Base
  def initialize(city: nil, title: nil, query:)
    @city = city
    @title = title
    @query = query
  end

  def view_template
    div(class: "w-full sticky top-0 py-2 z-10 bg-base-300") do
      div(class: "flex justify-between items-center mx-4") do
        div(class: "flex items-end w-full font-bold text-2xl md:text-3xl text-red-500 dark:text-white") {
          img(src: image_path("icon2.png"), class: "size-12", loading: "lazy")
          plain div(class: "-ml-6 -mb-1") {
            plain div(class: "text-base ml-3 -mb-2 text-red-700/50 dark:text-slate-300") { @city }
            plain @title
          }
        }
        a(href: new_entry_path, class: "rounded-full size-12 flex px-3.5 py-2.5 bg-blue-600 hover:bg-blue-500 text-white block font-medium",
                              data: { turbo_frame: "entry_modal" }) do
          lucide_icon(:pencil)
        end
      end
    end
    # форма поиска
    div(class: "w-full p-4 mb-4 bg-base-300") do
      form_with(url: root_path, method: :get, data: {
        controller: "search",
        search_target: "form",
        turbo_frame: "entries_list"
      }) do |f|
        div(class: "relative group") do
          f.text_field :query,
                      value: @query,
                      placeholder: "Поиск по объявлениям...",
                      class: "w-full pl-10 h-10 rounded-2xl bg-base-100",
                      data: { search_target: "input", action: "input->search#update" }
          # иконка поиска (слева)
          div(class: "absolute left-3 top-2.5 opacity-50 z-1") { lucide_icon("search", size: 20) }
          # Кнопка очистки (справа)
          # Показывает только когда input не пустой (peer-focus)
          button(type: "button",
                class: "absolute right-3 top-3 opacity-50 hover:opacity-100 z-10 hidden peer-[:not(:placeholder-shown)]:block",
                data: { action: "click->search#reset" }) do
            lucide_icon("x")
          end
        end
      end
    end
  end
end
