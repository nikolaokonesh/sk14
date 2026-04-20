# frozen_string_literal: true

class Views::Entries::Index < Views::Base
  def initialize(page:)
    @page = page
  end

  def view_template
    # Стрим и карточку-приветствие рендерим только на самой первой странице
    if @page.first?
      turbo_stream_from(:entries)
      render Components::Entries::IndexCardTop.new
      ul(id: "entries_list", class: "list bg-base-100 rounded-box shadow-md") do
        render_records
        render_next_page_frame
      end
    else
      turbo_frame_tag "entries_page_#{@page.number}" do
        render_records
        render_next_page_frame # Рендерим фрейм для СЛЕДУЮЩЕЙ страницы внутри текущего
      end
    end
  end

  private

  def render_records
    user = current_user
    @page.records.each do |entry|
      render Components::Entries::Card.new(entry: entry, user: user)
    end
  end

  def render_next_page_frame
    unless @page.last?
      turbo_frame_tag "entries_page_#{@page.next_param}",
                      src: entries_path(page: @page.next_param),
                      loading: :lazy,
                      target: "_top",
                      refresh: :morph do
        div(class: "flex justify-center p-6") { span(class: "loading loading-dots text-primary") }
      end
    end
  end
end
