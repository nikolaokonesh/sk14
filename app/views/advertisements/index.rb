# frozen_string_literal: true

class Views::Advertisements::Index < Views::Base
  def initialize(page:, advertisement:)
    @page = page
    @advertisement = advertisement
  end

  def view_template
    if @page.first?
      section(class: "py-4 px-2 space-y-5") do
        h1(class: "text-3xl font-black tracking-tight") { "Бизнес и административная реклама" }
        p(class: "opacity-70 text-sm") { "Реклама создаётся как пост: rich text контент, а заголовок кешируется автоматически." }

        if @advertisement
          render_form
        else
          a(href: auth_sign_path, class: "btn btn-primary btn-block rounded-2xl") { "Войти, чтобы добавить рекламу" }
        end

        div(class: "flex overflow-x-auto snap-x snap-mandatory no-scrollbar gap-4 pb-4", id: "advertisements_list") do
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
    @page.records.each { |advertisement| render_card(advertisement) }
  end

  def render_card(advertisement)
    a(href: advertisement_path(advertisement), class: "snap-center shrink-0 w-72 rounded-3xl p-[1px] bg-gradient-to-r #{advertisement.theme_gradient} shadow-xl") do
      article(class: "bg-base-100 rounded-3xl overflow-hidden p-4") do
        p(class: "text-xs opacity-60 mb-2") { "В топе · #{advertisement.user.name}" }
        h2(class: "text-xl font-extrabold mb-2 line-clamp-2") { advertisement.title }
        p(class: "text-sm opacity-80 line-clamp-4") { advertisement.content.to_plain_text }
        render_moderation_controls(advertisement)
      end
    end
  end

  def render_next_page_frame
    unless @page.last?
      turbo_frame_tag "advertisements_page_#{@page.next_param}",
                      src: advertisements_path(page: @page.next_param),
                      loading: :lazy,
                      target: "_top",
                      refresh: :morph do
        div(class: "flex items-center px-4") { span(class: "loading loading-dots text-primary") }
      end
    end
  end

  def render_moderation_controls(advertisement)
    return unless can?(:update, advertisement)

    div(class: "mt-3 flex flex-wrap gap-2") do
      form_with(model: advertisement, method: :patch, class: "inline") do |form|
        plain form.hidden_field :active, value: (!advertisement.active?).to_s
        plain form.hidden_field :top_placement, value: advertisement.top_placement
        plain form.hidden_field :paid_until, value: advertisement.paid_until
        plain form.submit(advertisement.active? ? "Скрыть" : "Показать", class: "btn btn-xs rounded-xl")
      end
    end
  end

  def render_form
    form_with(model: @advertisement, class: "bg-base-200 rounded-3xl p-4 space-y-4 shadow") do |form|
      div do
        form.label :content, "Текст рекламы", class: "label font-bold"
        plain form.rich_text_area :content, class: "lexxy-content", placeholder: "Добавьте текст, фото и документы"
      end

      div do
        form.label :theme, "Тема карточки", class: "label font-bold"
        plain form.select :theme, Advertisement::THEMES.keys.map { |theme| [theme.titleize, theme] }, {}, class: "select select-bordered w-full rounded-2xl"
      end

      plain form.submit "Опубликовать рекламу", class: "btn btn-primary btn-block h-12 rounded-2xl"
    end
  end
end
