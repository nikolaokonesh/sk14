# frozen_string_literal: true

class Views::Base < Components::Base
  include Components

  PageInfo = Data.define(:title)

  def around_template
    render layout.new(page_info) do
      main(class: "w-full md:w-3xl xl:w-4xl mx-auto md:px-0 flex flex-col") do
        navbar do
          div(class: "flex items-center sticky top-0 bg-base-300 z-10") { render Components::Menu::Header.new }
        end
        super
        render Components::Shared::Flash.new
        navbar do
          div(class: "flex items-center sticky bottom-0 bg-base-300") { render Components::Menu::Bottom.new }
        end
      end
    end
  end

  def page_title
    "Sk14.ru"
  end

  def page_info
    PageInfo.new(title: page_title)
  end

  def navbar(&block)
    axcluded_controllers = %w[name auth auth_verification tags feeds trash]
    axcluded_actions = %w[new edit show]

    return if controller_name.in?(axcluded_controllers) ||
              action_name.in?(axcluded_actions)
    yield
  end
end
