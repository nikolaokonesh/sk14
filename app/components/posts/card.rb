# frozen_string_literal: true

class Components::Posts::Card < Phlex::HTML
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::Truncate
  register_value_helper :lucide_icon

  def initialize(
    post:,
    entry: nil
  )
    @post = post
    @entry = entry || post.entry
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
          a(href: edit_entry_path(@entry)) { "Редактировать" }
        end
        li do
          if @entry.trash?
            a(href: trash_path(@entry), data: { turbo_method: :put, turbo_confirm: "Вы точно хотите восстановить?" }) { "Восстановить" }
          else
            a(href: entry_path(@entry), data: { turbo_method: :delete, turbo_confirm: "Вы точно хотите удалить?" }) { "Удалить" }
          end
        end
      end
    end
  end

  def content
    render Components::Reactions::Interactive.new(
      entry: @entry,
      class_name: "group",
      with_controller: true
    ) do
      a(href: link_to_post_helper(@entry), class: "z-10 cursor-pointer") do
        plain truncate(@post.title, length: 200, omission: "... Читать далее")
        div(class: "opacity-30 text-xs text-right") { render Components::Shared::TimeAgoInWords.new(entry: @entry) }
      end
    end
  end

  private

  def link_to_post_helper(entry)
    entry.trash? ? trash_path(entry) : entry_path(entry)
  end
end
