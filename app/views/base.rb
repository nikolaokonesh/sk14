# frozen_string_literal: true

class Views::Base < Components::Base
  include Components

  PageInfo = Data.define(:title)

  def around_template
    render layout.new(page_info) do
      main(class: "w-full md:w-3xl xl:w-4xl mx-auto md:px-0 flex flex-grow") do
        div(class: "flex flex-col w-full") do
          div(class: "flex-1 scroll-smooth") do
            super
          end
          render Components::Shared::Flash.new
          turbo_frame_tag "entry_modal", refresh: "morph", data: { turbo_permanent: true }
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
    return if current_page?(auth_path) || current_page?(auth_verification_path) || controller_name == "name"
    yield(block)
  end
end
