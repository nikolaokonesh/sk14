# frozen_string_literal: true

class Views::Entries::Index < Views::Base
  # Добавляем records и read_entry_ids в initialize
  def initialize(page:, records:, afishas:, read_entry_ids:, top_advertisements: [])
    @page = page
    @records = records # Массив записей из контроллера
    @afishas = afishas
    @read_entry_ids = read_entry_ids # Set с ID прочтенных постов
    @top_advertisements = top_advertisements
  end

  def view_template
    if @page.first?
      turbo_stream_from(:entries)
      render Components::Entries::IndexCardTop.new

      render Components::Entries::AfishaSection.new(afishas: @afishas)
      render_ads_section

      ul(id: "entries_list", class: "list bg-base-100 rounded-box shadow-md") do
        render_records
        render_next_page_frame
      end
    else
      # Для бесконечной прокрутки (пагинации)
      turbo_frame_tag "entries_page_#{@page.number}" do
        render_records
        render_next_page_frame
      end
    end
  end

  private

  def render_ads_section
    return if @top_advertisements.blank?

    div(class: "mb-6 mt-2") do
      div(class: "flex items-center justify-between px-4 mb-3") do
        h2(class: "text-xl font-black tracking-tight") { "Реклама" }
        a(href: advertisements_path, class: "btn btn-ghost btn-xs") { "Вся реклама" }
      end

      div(class: "flex overflow-x-auto snap-x snap-mandatory no-scrollbar gap-4 px-4 pb-4") do
        @top_advertisements.each do |ad|
          div(class: "snap-center shrink-0 w-64") do
            # Важно: если в рекламе тоже нужно показывать статус "прочитано",
            # добавьте передачу read_entry_ids и туда
            render Components::Advertisements::Card.new(entryable: ad, compact: true)
          end
        end
      end
    end
  end

  def render_records
    user = current_user
    # Используем @records (массив), а не @page.records (relation),
    # чтобы избежать повторного запроса COUNT/SELECT
    @records.each do |entry|
      render Components::Entries::Card.new(
        entry: entry,
        user: user,
        read_entry_ids: @read_entry_ids
      )
    end
  end

  def render_next_page_frame
    unless @page.last?
      # Важно: добавляем page в URL, чтобы пагинация знала, что грузить дальше
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
