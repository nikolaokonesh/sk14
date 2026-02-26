# frozen_string_literal: true

class Components::Posts::Tags < Components::Base
  def initialize(
    post:
  )
    @post = post
  end

  def view_template
    div(class: "flex flex-wrap gap-2") do
      @post.tags.each do |tag|
        link_to tag.name, tag_path(tag.id), class: "text-xs badge px-1"
      end
    end
  end
end
