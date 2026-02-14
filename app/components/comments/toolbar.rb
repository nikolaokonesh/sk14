# frozen_string_literal: true

class Components::Comments::Toolbar < Phlex::HTML
  include Phlex::Rails::Helpers::Tag
  register_value_helper :lucide_icon

  def view_template
    tag.lexxy_toolbar(id: "toolbar_content") do
      button(class: "btn btn-circle btn-primary btn-sm mb-1", type: "button", name: "upload", data_command: "uploadAttachments") do
        lucide_icon("image", size: 18)
      end
    end
  end
end
