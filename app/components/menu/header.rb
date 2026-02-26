class Components::Menu::Header < Components::Base
  def initialize(
    city: nil, 
    title: nil
  )
    @city = city
    @title = title
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
        a(href: new_entry_path, class: "rounded-full size-12 flex px-3.5 py-2.5 bg-blue-600 hover:bg-blue-500 text-white block font-medium") do
          lucide_icon(:pencil)
        end
      end
    end
  end
end
