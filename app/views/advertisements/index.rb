# frozen_string_literal: true

class Views::Advertisements::Index < Views::Base
  def initialize(page:)
    @page = page
  end

  def view_template
    if @page.first?
      section(class: "py-4 px-2 space-y-5") do
        div(class: "flex items-center justify-between") do
          h1(class: "text-3xl font-black tracking-tight") { "Бизнес и административная реклама" }
          if current_user
            a(href: new_advertisement_path, class: "btn btn-primary btn-sm") { "Добавить" }
          end
        end

        p(class: "opacity-70 text-sm") { "Реклама создаётся как пост: rich text контент, а заголовок кешируется автоматически." }

        ul(class: "space-y-4", id: "advertisements_list") do
          render_records
          render_next_page_frame
        end
      end
    else
      turbo_frame_tag "advertisements_page_#{@page.number}" do
        render_records
        render_next_page_frame
      end
    end
  end

  private

  def render_records
    @page.records.each do |advertisement|
      li { render Components::Advertisements::Card.new(advertisement: advertisement, show_actions: true) }
    end
  end


  def render_next_page_frame
    unless @page.last?
      turbo_frame_tag "advertisements_page_#{@page.next_param}",
                      src: advertisements_path(page: @page.next_param),
                      loading: :lazy,
                      target: "_top",
                      refresh: :morph do
        div(class: "flex justify-center p-4") { span(class: "loading loading-dots text-primary") }
      end
    end
  end
end
