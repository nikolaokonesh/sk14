# frozen_string_literal: true

class Components::Posts::Card < Phlex::HTML
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::Truncate
  register_value_helper :lucide_icon

  def initialize(post:)
    @post = post
  end

  def view_template
    yield
  end

  def nav
    span(class: "hidden dropdown dropdown-end",
        data: { auth_visibility_target: "controls" }) do
      div(tabindex: 0, role: "button", class: "absolute -mt-4 px-1.5 cursor-pointer") { lucide_icon("ellipsis") }
      ul(tabindex: -1, class: "dropdown-content menu bg-base-300 z-10 rounded-box w-52 p-2 shadow-sm") do
        li do
          a(href: edit_entry_path(@post.entry), data: { turbo_frame: "entry_modal" }) { "Редактировать" }
        end
        li do
          if @post.entry.trash == true
            a(href: trash_path(@post.entry), data: { turbo_method: :put, turbo_confirm: "Вы точно хотите восстановить?" }) { "Восстановить" }
          else
            a(href: entry_path(@post.entry), data: { turbo_method: :delete, turbo_confirm: "Вы точно хотите удалить?" }) { "Удалить" }
          end
        end
      end
    end
  end

  def content
    plain truncate(@post.title, length: 200, omission: "... Читать далее")
    a(href: link_to_post_helper(@post), data: { turbo_frame: "_top" }) do
      span(aria_hidden: "true", class: "absolute inset-0") { }
    end
  end

  private

  def link_to_post_helper(post)
    post.entry.trash == true ? trash_path(post.entry) : entry_path(post.entry)
  end
end
