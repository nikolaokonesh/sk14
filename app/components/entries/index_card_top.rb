# frozen_string_literal: true

class Components::Entries::IndexCardTop < Components::Base
  def view_template
    div(class: "card mx-auto") do
      unless current_user
        div(class: "card-body") do
          div(class: "flex justify-between") do
            span do
              h2(class: "text-3xl font-bold") { "SK14" }
              span(class: "badge badge-secondary badge-outline") { "Среднеколымск" }
            end
            span(class: "text-xl") { "Это бесплатно" }
          end
          ul(class: "flex flex-col gap-2 text-xs") do
            li { "Вы можете здесь" }
            li do
              plain raw lucide_icon("check", class: "size-4 me-2 inline-block text-success")
              span { "Написать своё объявление или важную статью" }
            end
            li do
              plain raw lucide_icon("check", class: "size-4 me-2 inline-block text-success")
              span { "Задать вопросы - получить ответы" }
            end
            li do
              plain raw lucide_icon("check", class: "size-4 me-2 inline-block text-success")
              span { "Оформить афишу грядущих событий" }
            end
            li { "Что ещё" }
            li do
              plain raw lucide_icon("check", class: "size-4 me-2 inline-block text-success")
              span { "Красивое оформление" }
            end
            li do
              plain raw lucide_icon("check", class: "size-4 me-2 inline-block text-success")
              span { "Подбор ключевых слов" }
            end
            li do
              plain raw lucide_icon("check", class: "size-4 me-2 inline-block text-success")
              span { "Таймер публикации" }
            end
            li do
              plain raw lucide_icon("check", class: "size-4 me-2 inline-block text-success")
              span { "Гибкая настройка" }
            end
          end
        end
      end
      a(href: new_entry_path, class: "btn btn-primary") { current_user ? "Добавить пост" : "Начать" }
    end
  end
end
