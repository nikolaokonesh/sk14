# frozen_string_literal: true

class Components::Comments::Page < Components::Base
  def initialize(entry:, page:)
    @entry = entry
    @page = page
  end

  def view_template
    if @page.first?
      turbo_frame_tag comments_container_id do
        div(id: dom_id(@entry, :comments), class: "space-y-3") do
          if @page.records.empty?
            render_empty_state
          else
            render_records
            render_next_page_frame
          end
        end
      end
    else
      turbo_frame_tag frame_id(@page.number) do
        render_records
        render_next_page_frame
      end
    end
  end

  private

  def render_records
    @page.records.each do |comment|
      render Components::Comments::Message.new(entry: comment, root_entry: @entry)
    end
  end

  def render_empty_state
    div(class: "rounded-2xl border border-dashed border-base-300 px-4 py-6 text-center") do
      p(class: "text-sm opacity-70") { "Пока нет комментариев. Будьте первым ✨" }
    end
  end

  def render_next_page_frame
    return if @page.last?

    turbo_frame_tag frame_id(@page.next_param),
                    src: entry_comments_path(@entry, page: @page.next_param),
                    loading: :lazy,
                    target: "_top",
                    refresh: :morph do
      div(class: "flex flex-col items-center gap-2 p-4") do
        span(class: "loading loading-dots text-primary")
        a(href: entry_comments_path(@entry, page: @page.next_param), class: "btn btn-ghost btn-xs") { "Загрузить ещё" }
      end
    end
  end

  def comments_container_id
    ActionView::RecordIdentifier.dom_id(@entry, :comments_container)
  end

  def frame_id(num)
    "entry_#{@entry.id}_comments_page_#{num}"
  end
end
