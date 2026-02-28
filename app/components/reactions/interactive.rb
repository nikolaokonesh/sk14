class Components::Reactions::Interactive < Phlex::HTML
  register_value_helper :authenticated?
  register_value_helper :lucide_icon

  def initialize(
    entry:,
    class_name:,
    id: nil,
    with_controller: false
  )
    @entry = entry
    @class_name = class_name
    @id = id
    @with_controller = with_controller
  end

  def view_template
    div(**container_options) do
      yield

      return unless Current.user

      div(class: "absolute hidden max-w-[70vw] md:max-w-[92vw] bottom-0 flex justify-center animate-in zoom-in duration-250 z-90", data: { reactions_target: "picker" }) do
        render Components::Reactions::Picker.new(entry: @entry)
      end

      div(class: "flex items-center relative z-30") do
        render Components::Reactions::List.new(entry: @entry)
        div(class: "ml-auto px-1.5") do
          button(
            type: "button",
            class: "btn btn-xs btn-circle z-50 opacity-20 hover:opacity-70 focus:opacity-70 duration-250 transition-all",
            data: { action: "click->reactions#togglePicker" },
            aria_label: "Выбрать реакцию"
          ) { lucide_icon("smile-plus", size: 18) }
        end
      end
    end
  end

  private

  def container_options
    data = {}
    data[:controller] = "reactions" if @with_controller

    options = { class: @class_name, data: data }
    options[:id] = @id if @id
    options
  end
end
