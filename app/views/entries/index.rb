# frozen_string_literal: true

class Views::Entries::Index < Views::Base
  def initialize(page:, afishas:, top_advertisements: [])
    @page = page
    @afishas = afishas
    @top_advertisements = top_advertisements
  end

  def view_template
    if @page.first?
      turbo_stream_from(:entries)
      render Components::Entries::IndexCardTop.new

      render Components::Entries::AfishaSection.new(afishas: @afishas)
      render_ads_section

      if @top_advertisement
        article(class: "mb-4 rounded-3xl p-[1px] bg-gradient-to-r #{@top_advertisement.theme_gradient}") do
          div(class: "rounded-3xl bg-base-100 p-3") do
            p(class: "text-xs opacity-60") { "Промо-блок сообщества" }
            h2(class: "font-bold") { @top_advertisement.title }
            p(class: "text-sm opacity-80 mb-2") { @top_advertisement.description }
            div(class: "flex gap-2") do
              a(href: @top_advertisement.cta_url, target: "_blank", rel: "noopener", class: "btn btn-primary btn-sm rounded-xl") { @top_advertisement.cta_text }
              a(href: advertisements_path, class: "btn btn-ghost btn-sm rounded-xl") { "Добавить свою" }
            end
          end
        end
      else
        a(href: advertisements_path, class: "btn btn-outline btn-block mb-4 rounded-2xl") { "Добавить рекламу в топ" }
      end

      ul(id: "entries_list", class: "list bg-base-100 rounded-box shadow-md") do
        render_records
        render_next_page_frame
      end
    else
      turbo_frame_tag "entries_page_#{@page.number}" do
        render_records
        render_next_page_frame
      end
    end
  end

  private

  def render_ads_section
    if @top_advertisements.any?
      div(class: "mb-6 mt-2") do
        div(class: "flex items-center justify-between px-4 mb-3") do
          h2(class: "text-xl font-black tracking-tight") { "Реклама" }
          a(href: advertisements_path, class: "btn btn-ghost btn-xs") { "Вся реклама" }
        end

        div(class: "flex overflow-x-auto snap-x snap-mandatory no-scrollbar gap-4 px-4 pb-4") do
          @top_advertisements.each do |advertisement|
            a(href: advertisement_path(advertisement), class: "snap-center shrink-0 w-64 rounded-2xl p-[1px] bg-gradient-to-r #{advertisement.theme_gradient}") do
              div(class: "bg-base-100 rounded-2xl p-3") do
                h3(class: "font-bold line-clamp-2 mb-1") { advertisement.title }
                p(class: "text-sm opacity-80 line-clamp-3") { advertisement.content.to_plain_text }
              end
            end
          end
        end
      end
    else
      a(href: advertisements_path, class: "btn btn-outline btn-block mb-4 rounded-2xl") { "Добавить рекламу в топ" }
    end
  end

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
