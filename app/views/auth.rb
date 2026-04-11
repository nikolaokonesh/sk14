# frozen_string_literal: true

class Views::Auth < Components::Base
  include Components

  PageInfo = Data.define(:title)

  def around_template
    render Layout.new(page_info) do
      super
    end
  end

  def page_title
    "Sk14.ru - войти"
  end

  def page_info
    PageInfo.new(title: page_title)
  end
end
