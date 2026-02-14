# frozen_string_literal: true

class Components::Menu::Back < Phlex::HTML
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::LinkTo
  register_value_helper :lucide_icon

  def view_template
    div(class: "flex w-full sticky top-0 z-10 bg-base-300") do
      link_to lucide_icon("chevron-left"), "javascript:history.go(-1)", class: "btn btn-ghost p-2 active:text-red-500"
    end
  end
end
