class Components::Menu::Search < Components::Base
  def initialize(
    query:,
    categories:,
    counts:
  )
    @query = query
    @categories = categories
    @counts = counts
  end

  def view_template
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
                      class: "w-full pl-10 h-10 rounded-2xl bg-base-100 peer",
                      data: { search_target: "input", action: "input->search#update" }
          # иконка поиска (слева)
          div(class: "absolute left-3 top-2.5 opacity-50 z-1") { lucide_icon("search", size: 20) }
          # Кнопка очистки (справа)
          # Показывает только когда input не пустой (peer-focus)
          button(type: "button",
                class: "absolute right-3 top-2.5 opacity-50 hover:opacity-100 z-10 hidden peer-[:not(:placeholder-shown)]:block",
                data: { action: "click->search#reset" }) do
            lucide_icon("x")
          end
        end
        div(class: "mt-4") do
          render Views::Tags::Search.new(
            categories: @categories,
            counts: @counts,
            query: @query
          )
        end
      end
    end
  end
end
