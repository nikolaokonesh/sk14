# frozen_string_literal: true

class Components::Comments::Form::Edit < Phlex::HTML
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::Tag
  include Phlex::Rails::Helpers::DOMID
  register_value_helper :lucide_icon

  def initialize(entry:)
    @comment = entry
    @entry = entry.entry
  end

  def view_template
    div(id: "comment_content_chat_#{@comment.id}") do
      div(id: dom_id(@comment), class: "edit_form_comment") do
        form_with(model: [ @entry, @comment ],
          class: "flex items-end gap-2") do |f|
          # render Components::Comments::Toolbar.new
          div(class: "relative flex-1 group comment_editor  min-w-[200px]") do
            div(id: "comment_edit_error_#{@comment.id}") { }
            f.rich_text_area :content,
            toolbar: false,
            placeholder: "Напишите комментарий",
            class: "pr-4 p-2 rounded-2xl border-none focus:ring-1 text-sm focus:ring-primary w-full overflow-y-auto" do
              render Components::Comments::Form::LexxyPrompt.new(entry: @entry.root)
            end
          end

          f.button(type: "submit", class: "btn btn-circle btn-primary btn-sm mb-1") do
            lucide_icon("send", size: 18)
          end
        end
      end
      a(href: cancel_edit_entry_comment_path(@entry, @comment),
        class: "btn btn-ghost btn-xs",
        data: { turbo_stream: true, turbo_prefetch: "false" }) { "Отмена" }
    end
  end
end
