# frozen_string_literal: true

class Components::Comments::Form::Create < Phlex::HTML
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::Tag
  register_value_helper :lucide_icon

  def initialize(entry:, comment: Comment.new, pagy_has_next:, pagy:)
    @entry = entry
    @comment = comment
    @pagy_has_next = pagy_has_next
    @pagy = pagy
  end

  def view_template
    div(id: "reply_container", data: { reply_target: "container" }, class: "hidden flex-row items-center justify-between bg-base-300 border-l-4 border-primary px-4 py-2 mx-2 mb-1 rounded-r-lg shadow-sm animate-fade-in-up") do
      div(class: "flex flex-col overflow-hidden mr-4") do
        span(data: { reply_target: "author" }, class: "text-primary text-sm font-bold truncate") { "" }
        span(data: { reply_target: "text" }, class: "text-base-content/70 text-xs truncate") { "" }
      end

      button(data: { action: "click->reply#close" }, class: "btn btn-ghost btn-xs btn-circle") do
        lucide_icon("x", class: "size-4")
      end
    end

    form_with(model: [ @entry, @comment ],
      id: "comment_from_container",
      class: "flex items-end gap-2",
      data: { controller: "reset-form", action: "turbo:submit-start->reset-form#prepareSubmission
                                                 turbo:submit-end->reset-form#reset
                                                 turbo:submit-end->reply#submitEnd
                                                 #{go_to_latest}" }) do |f|
      # render Components::Comments::Toolbar.new
      f.hidden_field :parent_id, data: { reply_target: "input" }

      div(class: "relative flex-1 group comment_editor") do
        div(id: "comment_create_error") { }
        f.rich_text_area :content,
        toolbar: false,
        data: { reset_form_target: "input", reply_target: "textarea" },
        placeholder: "Напишите комментарий",
        class: "pr-4 p-2 rounded-2xl border-none focus:ring-1 focus:ring-primary w-full" do
          render Components::Comments::Form::LexxyPrompt.new(entry: @entry.root)
        end
      end
      f.button(type: "submit", class: "btn btn-circle btn-primary btn-sm mb-1") do
        lucide_icon("send", size: 18)
      end
    end
  end

  def go_to_latest
    @pagy&.next || @pagy_has_next ? "turbo:submit-end->reply#goToLatest" : ""
  end
end
