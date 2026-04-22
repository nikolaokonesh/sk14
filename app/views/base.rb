# frozen_string_literal: true

class Views::Base < Components::Base
  include Components

  PageInfo = Data.define(:title)

  def around_template
    render Layout.new(page_info) do
      main(class: "w-full md:w-2xl mx-auto") do
        render Menu::Topbar.new
        super
      end
    end
  end

  def page_title
    "Sk14.ru"
  end

  def page_info
    PageInfo.new(title: page_title)
  end
end
