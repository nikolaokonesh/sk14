# frozen_string_literal: true

class Components::Pagination::Skeleton < Phlex::HTML
  def view_template
    div(class: "flex justify-center p-2 my-5") { span(class: "loading loading-dots loading-base") }
  end
end
