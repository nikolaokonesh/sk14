# frozen_string_literal: true

class Views::Advertisements::Show < Views::Base
  def initialize(advertisement:)
    @advertisement = advertisement
  end

  def view_template
    article(class: "py-4 px-2") do
      div(class: "rounded-3xl p-[1px] bg-gradient-to-r #{@advertisement.theme_gradient} shadow-xl") do
        div(class: "bg-base-100 rounded-3xl overflow-hidden") do
          div(class: "p-5") do
            p(class: "text-xs opacity-60") { "Рекламная публикация · #{@advertisement.user.name}" }
            h1(class: "text-3xl font-black mt-2 mb-4") { @advertisement.title }
            div(class: "prose max-w-none") { plain @advertisement.content }

            if can?(:update, @advertisement)
              div(class: "mt-6 flex flex-wrap gap-2") do
                a(href: edit_advertisement_path(@advertisement), class: "btn btn-sm btn-primary") { "Редактировать" }

                form_with(model: @advertisement, method: :delete, class: "inline") do |form|
                  plain form.submit "Удалить", class: "btn btn-sm btn-error", data: { turbo_confirm: "Удалить рекламу?" }
                end
              end
            end
          end
        end
      end
    end
  end
end
